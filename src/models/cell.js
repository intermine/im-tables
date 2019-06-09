/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let CellModel;
const _ = require('underscore');
const {Promise} = require('es6-promise');
const Options = require('../options');
const CoreModel = require('../core-model');

const DELIM = 'DynamicObjects.NameDelimiter';

// Forms a pair with ./nested-table
module.exports = (CellModel = class CellModel extends CoreModel {

  defaults() {
    return {
      columnName: null,
      typeName: null,
      typeNames: [],
      entity: null, // :: IMObject
      column: null, // :: PathInfo
      node: null, // :: PathInfo
      field: null, // :: String
      value: null // :: Any
    };
  }

  initialize() {
    let column, left;
    super.initialize(...arguments);
    const types = ((left = this.get('entity').get('classes')) != null ? left : [this.get('node')]);
    const {model} = (column = this.get('column'));
    column.getDisplayName().then(columnName => this.set({columnName}));
    const nameRequests = (Array.from(types).map((t) => model.makePath(t).getDisplayName()));
    return Promise.all(nameRequests).then(names => {
      return this.set({typeNames: names, typeName: names.join(Options.get(DELIM))});
    });
  }

  getPath() { return this.get('column'); }

  toJSON() { return _.extend(super.toJSON(...arguments), {
    column: this.get('column').toString(),
    node: this.get('node').toString(),
    entity: this.get('entity').toJSON()
  }
  ); }
});
