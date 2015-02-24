_ = require 'underscore'
{Promise} = require 'es6-promise'
Options = require '../options'
CoreModel = require '../core-model'

DELIM = 'DynamicObjects.NameDelimiter'

# Forms a pair with ./nested-table
module.exports = class CellModel extends CoreModel

  defaults: ->
    columnName: null
    typeName: null
    typeNames: []
    entity: null # :: IMObject
    column: null # :: PathInfo
    node: null # :: PathInfo
    field: null # :: String
    value: null # :: Any

  initialize: ->
    super
    types = (@get('entity').get('classes') ? [@get('node')])
    {model} = column = @get('column')
    column.getDisplayName().then (columnName) => @set {columnName}
    nameRequests = (model.makePath(t).getDisplayName() for t in types)
    Promise.all(nameRequests).then (names) =>
      @set typeNames: names, typeName: names.join(Options.get DELIM)

  getPath: -> @get('column')

  toJSON: -> _.extend super,
    column: @get('column').toString()
    node: @get('node').toString()
    entity: @get('entity').toJSON()
