let RowsCollection;
const _ = require('underscore');

const CoreModel = require('../core-model');
const Collection = require('../core/collection');

// A row in the table, basically just a container for cells.
class RowModel extends CoreModel {

  defaults() {
    return {
      index: null,
      query: null, // string for caching skipsets
      cells: []
    };
  }

  toJSON() { return _.extend(super.toJSON(...arguments), {cells: ((Array.from(this.get('cells')).map((c) => c.toJSON())))}); }
}

// An ordered collection of rows
// It indexes rows by index, so it must be reset if the query changes.
module.exports = (RowsCollection = (function() {
  RowsCollection = class RowsCollection extends Collection {
    static initClass() {
  
      this.prototype.model = RowModel;
  
      this.prototype.comparator = 'index';
    }
  };
  RowsCollection.initClass();
  return RowsCollection;
})());

