CoreModel = require '../core-model'

# Forms a pair with models/cell
#
module.exports = class NestedTableModel extends CoreModel

  defaults: ->
    columnName: null
    typeName: null
    column: null # :: PathInfo
    node: null # :: PathInfo
    rows: [] # [CellModel]

  initialize: ->
    @setNames()
    @listenTo @, 'change:column', @onChangeColumn # Should never happen.

  onChangeColumn: -> # Set the display names.
    column = @get 'column'
    column.getDisplayName().then (name) => @set columnName: name
    column.getType().getDisplayName().then (name) => @set columnTypeName: name

  getPath: -> @get 'column'
