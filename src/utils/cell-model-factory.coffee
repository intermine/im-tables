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

  constructor: (@query) ->
    @itemModels = new ObjectStore @query.service.root, @query.model

  # Take a cell returned from the web-service and produce a model.
  createModel: (cell) ->
    if _.has(cell, 'rows')
      @_make_sub_table_model cell
    else
      @_make_simple_cell_model cell

  _make_sub_table_model: (nestedTable) ->
    # Here we lift some properties to more useful types, then wrap it up in
    # a structured object.
    node = @query.makePath nestedTable.column

    new NestedTableModel _.extend {}, nestedTable, # TODO: do we need to assign from nestedTable?
      node: node # Duplicate name - not necessary?
      column: node
      rows: (r.map((subcell) => @createModel subcell) for r in nestedTable.rows)

  _make_simple_cell_model: (obj) ->
    column = @query.makePath(obj.column) # The attr this cell represents (eg. Employee.name)
    node = column.getParent()            # The obj this attr belongs to (eg. Employee)
    field = obj.column.replace(/^.*\./, '')

    model = if obj.id?
      @itemModels.get obj, field # Get or create 
    else if not obj.class? # create a new null-cell for this cell.
      type = node.getParent().name
      new NullObject {}, {@query, field, type}
    else # FastPathObjects don't have ids, and cannot be in lists.
      new FPObject {}, {@query, obj, field}

    # A cell model is a nested model, containing cell, a sub-model containing
    # the data for this entity, not just this cell.
    # There is one CellModel for each cell displayed in the table, but there is only one
    # InterMineObject for each entity represented in the table.
    new CellModel
      entity: model
      node: node
      column: column
      field: field
      value: obj.value

  destroy: ->
    @itemModels?.destroy()
    delete @query
    delete @itemModels
    this
