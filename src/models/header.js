// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let HeaderModel;
const _ = require('underscore');
const PathModel = require('./path');
const Options = require('../options');

const uc = s => s != null ? s.toUpperCase() : undefined;
const firstResult = _.compose(_.first, _.compact, _.map);

const looksLikePath = r => (r != null) && (r.isReference != null) && (r.isAttribute != null);

// Model of each column header in the table.
// Managed model - needs reference to the query, so
// that it may listen to update properties such as
// sortable, sortDirection, numOfCons, etc
module.exports = (HeaderModel = class HeaderModel extends PathModel {

  defaults() { return _.extend(super.defaults(...arguments), {
    replaces: [],
    isFormatted: false,
    isComposed: false,
    sortable: true,
    sortDirection: null,
    numOfCons: 0,
    minimised: false,
    outerJoined: false,
    expanded: Options.get('Subtables.Initially.Expanded')
  }
  ); }

  // The query is needed to update derived properties.
  constructor(opts, query) {
    if (opts == null) { throw new Error('no options'); }
    super(opts.path);
    this.query = query;
    if (!(this.query != null ? this.query.on : undefined)) { throw new Error('no query'); }
    this.set(_.omit(opts, 'path'));
    // ID depends on query as well as path.
    this.set({id: `${ this.query.toXML() }-${ this.get('path') }`});
    this.listenTo(this.query, 'change:joins', this.setOuterJoined);
    this.listenTo(this.query, 'change:sortorder', this.setSortDirection);
    this.listenTo(this.query, 'change:constraints', this.setConstraintNum);
    this._update_attrs();
  }

  _update_attrs() {
    this.setOuterJoined();
    this.setSortDirection();
    return this.setConstraintNum();
  }

  // the output of this method must be serializable, so we stringify the paths.
  toJSON() { return _.extend(super.toJSON(...arguments), {replaces: this.get('replaces').map(String)}); }

  getView() {
    const {replaces, isFormatted, path} = this.pick('replaces', 'isFormatted', 'path');
    return String((isFormatted && (replaces.length === 1)) ? replaces[0] : path);
  }

  validate(attrs, opts) {
    if ('replaces' in attrs) {
      const rs = attrs.replaces;
      if (!_.isArray(rs)) {
        return new Error('replaces must be an array');
      }
      if ((rs.length) && (!_.all(rs, looksLikePath))) {
        return new Error('all elements in replaces must be PathInfo objects');
      }
    }
  }

  setOuterJoined() {
    const view = this.getView();
    const replaces = this.get('replaces');
    const outerJoined = this.query.isOuterJoined(view);
    // This column is composed if it represents more than one replaced column.
    const isComposed = this.get('isFormatted') && (replaces.length > 1);
    const sortable = !outerJoined;
    return this.set({outerJoined, isComposed, sortable});
  }

  setSortDirection() {
    const replaces = this.get('replaces');
    const view = this.getView();
    const getDirection = p => this.query.getSortDirection(p);
    // Work out the sort direction of this column (which is the sort
    // direction of the path or the first available sort direction of
    // the paths it replaces in the case of formatted columns).
    const direction = uc(firstResult(replaces.concat([view]), getDirection));
    return this.set({sortDirection: direction});
  }

  setConstraintNum() {
    const view = this.getView();
    const numOfCons = _.size((() => {
      const result = [];
      for (let c of Array.from(this.query.constraints)) {         if (c.path.match(view)) {
          result.push(c);
        }
      }
      return result;
    })());
    return this.set({numOfCons});
  }
});

