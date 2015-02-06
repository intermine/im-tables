CoreModel = require '../core-model'

# Forms a pair with ./nested-table
module.exports = class CellModel extends CoreModel

  defaults: ->
    columnName: null
    typeName: null
    entity: null # :: IMObject
    column: null # :: PathInfo
    node: null # :: PathInfo
    field: null # :: String
    value: null # :: Any

  initialize: ->
    super
    type = (@get('entity').get('class') ? @get('node'))
    column = @get('column')
    column.getDisplayName().then (columnName) => @set {columnName}
    column.model.makePath(type).getDisplayName().then (typeName) => @set {typeName}

  toJSON: -> _.extend super, entity: @get('entity').toJSON()
