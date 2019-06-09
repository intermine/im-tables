/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Preview;
const _ = require('underscore');
const {Promise} = require('es6-promise');

const Templates = require('../templates');
const CoreView = require('../core-view');
const CoreModel = require('../core-model');
const Options = require('../options');
const Collection = require('../core/collection');
const PathModel = require('../models/path');
let types = require('../core/type-assertions');
const getLeaves = require('../utils/get-leaves');

const ItemDetails = require('./item-preview/details');
const ReferenceCounts = require('./item-preview/reference-counts');
const CountsTitle = require('./item-preview/counts-title');

const cantFindField = (fld, types) => `Could not determine origin of ${ fld } from [${ types.join(', ') }]`;

class DetailsModel extends PathModel {

  constructor(opts) {
    super(opts.path);
    this.set(_.omit(opts, 'path'));
  }
}

class AttrDetailsModel extends DetailsModel {

  defaults() { return _.extend(super.defaults(...arguments), {
    fieldType: 'ATTR',
    valueOverspill: null,
    tooLong: false,
    value: null
  }
  ); }
}

class RefDetailsModel extends DetailsModel {

  defaults() { return _.extend(super.defaults(...arguments), {
    fieldType: 'REF',
    values: []
  }); }
}

class SortedByName extends Collection {
  static initClass() {
  
    this.prototype.comparator = 'displayName';
  }

  initialize() {
    return this.listenTo(this, 'change:displayName', this.sort);
  }
}
SortedByName.initClass();

// the model for the preview needs a type and an id.
class PreviewModel extends CoreModel {

  defaults() {
    return {
      types: [],
      id: null,
      error: null,
      phase: 'FETCHING' // one of FETCHING, SUCCESS, ERROR
    };
  }
}

const ERROR = Templates.template('cell-preview-error');

const HIDDEN_FIELDS = ['class', 'objectId']; // We don't show these fields.

// fn version of Array.concat
const concat = (xs, ys) => xs.concat(ys);
// Accept non-null attrs.
const acceptAttr = () => (f, v) => (v != null) && (!v.objectId) && (!Array.from(HIDDEN_FIELDS).includes(f));
// Accept references.
const acceptRef = () => (f, v) => v != null ? v.objectId : undefined;

// Define the bits of the service we need.
const ServiceType = new types.Structure('ServiceType', {
  root: types.String,
  count: types.Function,
  findById: types.Function,
  fetchModel: types.Function
}
);

module.exports = (Preview = (function() {
  Preview = class Preview extends CoreView {
    constructor(...args) {
      {
        // Hack: trick Babel/TypeScript into allowing this before super.
        if (false) { super(); }
        let thisFn = (() => { return this; }).toString();
        let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
        eval(`${thisName} = this;`);
      }
      this.handleItem = this.handleItem.bind(this);
      super(...args);
    }

    static initClass() {
  
      this.prototype.Model = PreviewModel;
  
      this.prototype.className = 'im-cell-preview-inner';
  
      this.prototype.parameters = ['service'];
  
      this.prototype.parameterTypes =
        {service: ServiceType};
  
      this.prototype.fetching = null;
    }

    initialize() {
      super.initialize(...arguments);
      this.fieldDetails = new SortedByName;
      return this.referenceFields = new SortedByName;
    }

    modelEvents() {
      return {
        'change:phase': this.reRender,
        'change:error': this.reRender
      };
    }

    remove() {
      this.removeAllChildren();
      this.fieldDetails.close();
      this.referenceFields.close();
      delete this.fieldDetails;
      delete this.referenceFields;
      return super.remove(...arguments);
    }

    template({phase, error}) { switch (phase) {
      case 'FETCHING': return this.helpers().IndeterminateProgressBar;
      case 'ERROR': return ERROR(error);
      default: return null;
    } }

    preRender() { // Fetch data, but no more than once.
      const m = this.model;
      if (this.fetching == null) { this.fetching = this.fetchData(); }
      return this.fetching.then((() => m.set({phase: 'SUCCESS'})), function(e) {
        console.error(e);
        return m.set({phase: 'ERROR', error: e});
      });
    }

    postRender() { if ('SUCCESS' === this.model.get('phase')) {
      return Array.from(this.model.get('types')).map((t) =>
        this.$el.addClass(t));
    } }

    renderChildren() {
      const itemDetailsTable = new ItemDetails({collection: this.fieldDetails});
      this.renderChild('details', itemDetailsTable);

      const countsTitle = new CountsTitle({collection: this.referenceFields});
      this.renderChild('counttitle', countsTitle);

      const referenceCounts = new ReferenceCounts({collection: this.referenceFields});
      this.renderChild('counts', referenceCounts);

      return this.$el.append(Templates.clear);
    }

    // Fetching requires the InterMine data model, which we name
    // schema here for reasons of sanity (namely collision with the
    // Backbone model located at @model)
    fetchData() { return this.service.fetchModel().then(schema => {

      this.schema = schema;
      const gettingDetails = this.getAllDetails();

      if (Options.get('ItemDetails.ShowReferenceCounts')) {
        const gettingCounts = this.getRelationCounts();
        return Promise.all(gettingDetails.concat(gettingCounts));
      } else {
        return Promise.all(gettingDetails);
      }
    }); }

    getAllDetails() { return (Array.from(this.model.get('types')).map((t) => this.getDetails(t))); }

    getDetails(type) {
      const id = this.model.get('id');
      const fields = Options.get(['ItemDetails', 'Fields', this.schema.name, type]);
      return this.service.findById(type, id, fields).then(this.handleItem);
    }

    // Reads values from the returned items and adds details objects to the
    // fieldDetails and referenceFields collections, avoiding duplicates.
    handleItem(item) {
      let field, value;
      const coll = this.fieldDetails;
      const testAttr = acceptAttr(coll);
      const testRef = acceptRef(coll);
      const clds = (Array.from(this.model.get('types')).map((t) => this.schema.classes[t]));

      for (field in item) {
        value = item[field];
        if (testAttr(field, value)) {
          this.handleAttribute(item, clds, field, value);
        }
      }

      for (field in item) {
        value = item[field];
        if (testRef(field, value)) {
          this.handleSubObj(item, clds, field, value);
        }
      }

      return null;
    }

    getPathForField(clds, field) {
      let path;
      const cld = _.find(clds, c => c.fields[field] != null);
      if (cld == null) { throw new Error(cantFindField(field, _.pick(clds, 'name'))); }
      return path = this.schema.makePath(`${ cld.name }.${ field }`);
    }

    // Turns references returned from into name: values pairs
    handleSubObj(item, clds, field, value) {
      const path = this.getPathForField(clds, field);
      const values = getLeaves(value, HIDDEN_FIELDS);
      const details = {path, field, values};

      return this.fieldDetails.add(new RefDetailsModel(details));
    }

    handleAttribute(item, clds, field, rawValue) {
      const path = this.getPathForField(clds, field);
      const details = {path, field, value: rawValue};

      if (((rawValue != null) && (path.getType() === 'String')) || (/Clob/.test(path.getType()))) {
        const cuttoff = Options.get('CellCutoff');
        const valueString = String(rawValue);
        const tooLong = rawValue.length > cuttoff;
        if (tooLong) { // Try and break on whitespace
          let snipPoint = valueString.indexOf(' ', cuttoff * 0.9);
          if (snipPoint === -1) { snipPoint = cuttoff; } // too bad, break here then.
          details.tooLong = true;
          details.valueOverspill = valueString.substring(snipPoint);
          details.value = valueString.substring(0, snipPoint);
        }
      }

      return this.fieldDetails.add(new AttrDetailsModel(details));
    }

    getRelationCounts() {
      let left;
      types = this.model.get('types');
      const { root } = this.service;
      const opts = ((left = Options.get(['ItemDetails', 'Count', root]))) != null ? left : {};

      const countSets = (() => {
        const result = [];
        for (var type of Array.from(types)) {
          var cld = this.schema.classes[type];
          result.push((Array.from(opts[type] != null ? opts[type] : ((() => {
            const result1 = [];
            for (let c in cld.collections) {
              result1.push(c);
            }
            return result1;
          })()))).map((settings) =>
            this.getRelationCount(settings, type)));
        }
        return result;
      })();

      // Flatten the sets of promises into a single collection.
      return countSets.reduce(concat, []);
    }

    getRelationCount(settings, type) {
      let counter, details;
      const id = this.model.get('id');

      if (_.isObject(settings)) {
        const {query, label} = settings;
        counter = query(id); // query is a function from id -> query
        details = c => new CoreModel({parts: [label], id: label, displayName: label, count: c});
      } else {
        const path = this.schema.makePath(`${ type }.${ settings }`);
        if (!__guard__(path.getType(), x => x.attributes.id)) { return Promise.resolve(true); } // Skip if no id.
        counter = {select: [settings + '.id'], from: type, where: {id}};
        details = c => new DetailsModel({path, count: c});
      }

      return this.service.count(counter)
              .then(details)
              .then(d => { if (d.get('count')) { return this.referenceFields.add(d); } });
    }
  };
  Preview.initClass();
  return Preview;
})());

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}