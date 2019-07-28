let CellModelFactory;
const _ = require('underscore');

const ObjectStore      = require('../models/object-store');
const NestedTableModel = require('../models/nested-table');
const CellModel        = require('../models/cell');
const NullObject       = require('../models/null-object');
const FPObject         = require('../models/fast-path-object');

// Factory that wraps an object store for constructing entity models
// with logic for handling other types of cell model, such as null 
// values, fast-path objects and sub-tables.
module.exports = (CellModelFactory = class CellModelFactory {

  constructor(service, model) {
    this.itemModels = new ObjectStore(service.root, model);
  }

  // Take a cell returned from the web-service and produce a model.
  getCreator(query) {
    let creator;
    if (!query) { throw new Error('No query'); }
    return creator = cell => {
      const path = query.makePath(cell.column);
      if (_.has(cell, 'rows')) {
        return this._make_sub_table_model(cell, path, creator);
      } else {
        return this._make_simple_cell_model(cell, path);
      }
    };
  }

  _make_sub_table_model(nestedTable, column, createModel) {
    // Here we lift some properties to more useful types, then wrap it up in
    // a structured object.

    // We assign from nestedTable to get access to properties such as .view
    return new NestedTableModel(_.extend({}, nestedTable, {
      node: column, // Duplicate name - not necessary?
      column,
      rows: ((Array.from(nestedTable.rows).map((r) => r.map(subcell => createModel(subcell)))))
    }
    )
    );
  }

  _make_simple_cell_model(obj, column) {
    // The obj this attr belongs to (eg. Employee)
    const node = column.getParent();
    // The raw attribute name.
    const field = column.end.name;

    // Can be either a full InterMineObject, a null placeholder, or
    // a light-weight fast-path object.
   
    const entity = (obj.id != null) ?
      this.itemModels.get(obj, field) // Get or create 
    : (obj.class == null) ? // create a new null-cell for this cell.
      new NullObject(node.getType().name, field)
    : // FastPathObjects don't have ids, and cannot be in lists.
      new FPObject(obj, field);

    // A cell model is a nested model, containing cell, a sub-model containing
    // the data for this entity, not just this cell.
    // There is one CellModel for each cell displayed in the table, but there
    // is only one InterMineObject for each entity represented in the table.
    return new CellModel({
      entity,
      node,
      column,
      field,
      value: obj.value
    });
  }

  destroy() {
    if (this.itemModels != null) {
      this.itemModels.destroy();
    }
    delete this.itemModels;
    return this;
  }
});
