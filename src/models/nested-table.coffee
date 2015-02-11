_ = require 'underscore'

CoreModel = require '../core-model'

# Forms a pair with models/cell
#
module.exports = class NestedTableModel extends CoreModel

  defaults: ->
    columnName: null
    columnTypeName: null
    columnName: null
    typeName: null
    column: null # :: PathInfo
    node: null # :: PathInfo
    fieldName: null
    contentName: null
    view: [] # [String]
    rows: [] # [CellModel]

  initialize: ->
    @onChangeColumn()
    @listenTo @, 'change:column', @onChangeColumn # Should never happen.

  onChangeColumn: -> # Set the display names.
    column = @get 'column'
    node = @get 'node'
    views = @get 'view'
    if views.length is 1 # Use the single column as our column.
      column = column.model.makePath(views[0], column.subclasses)
      node = if column.isAttribute() then column.getParent() else column

    node.getType().getDisplayName().then (name) => @set columnTypeName: name
    column.getDisplayName().then (name) =>
      console.log views, name
      @set columnName: name
      @set(fieldName: _.last(name.split ' > ')) if column.isAttribute()
      @set contentName: _.compact([@get('columnTypeName'), @get('fieldName')]).join(' ')

  getPath: -> @get 'column'

  toJSON: -> _.extend super,
    column: @get('column').toString()
    node: @get('node').toString()
    rows: @get('rows').map (r) -> r.map (c) -> c.toJSON()

