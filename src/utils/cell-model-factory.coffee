_ = require 'underscore'

ObjectStore      = require '../models/object-store'
NestedTableModel = require '../models/nested-table'
CellModel        = require '../models/cell'
NullObject       = require '../models/null-object'
FPObject         = require '../models/fast-path-object'

# Factory that wraps an object store for constructing entity models
# with logic for handling other types of cell model, such as null 
# values, fast-path objects and sub-tables.
module.exports = class CellModelFactory

  constructor: (service, model) ->
    @itemModels = new ObjectStore service.root, model

  # Take a cell returned from the web-service and produce a model.
  getCreator: (query) ->
    throw new Error('No query') unless query
    creator = (cell) =>
      path = query.makePath cell.column
      if _.has(cell, 'rows')
        @_make_sub_table_model cell, path, creator
      else
        @_make_simple_cell_model cell, path

  _make_sub_table_model: (nestedTable, column, createModel) ->
    # Here we lift some properties to more useful types, then wrap it up in
    # a structured object.

    # We assign from nestedTable to get access to properties such as .view
    new NestedTableModel _.extend {}, nestedTable,
      node: column # Duplicate name - not necessary?
      column: column
      rows: (r.map((subcell) -> createModel subcell) for r in nestedTable.rows)

  _make_simple_cell_model: (obj, column) ->
    # The obj this attr belongs to (eg. Employee)
    node = column.getParent()
    # The raw attribute name.
    field = column.end.name

    # Can be either a full InterMineObject, a null placeholder, or
    # a light-weight fast-path object.
   
    entity = if obj.id?
      @itemModels.get obj, field # Get or create 
    else if not obj.class? # create a new null-cell for this cell.
      new NullObject node.getType().name, field
    else # FastPathObjects don't have ids, and cannot be in lists.
      new FPObject obj, field

    # A cell model is a nested model, containing cell, a sub-model containing
    # the data for this entity, not just this cell.
    # There is one CellModel for each cell displayed in the table, but there
    # is only one InterMineObject for each entity represented in the table.
    new CellModel
      entity: entity
      node: node
      column: column
      field: field
      value: obj.value

  destroy: ->
    @itemModels?.destroy()
    delete @itemModels
    this
