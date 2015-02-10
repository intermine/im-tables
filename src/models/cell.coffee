_ = require 'underscore'
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
  
  getPath: -> @get('column')

  toJSON: -> _.extend super,
    column: @get('column').toString()
    node: @get('node').toString()
    entity: @get('entity').toJSON()
