CoreModel = require '../core-model'

# Forms a pair with ./nested-table
module.exports = class CellModel extends CoreModel

  initialize: ->
    super
    type = (@get('entity').get('class') ? @get('node'))
    column = @get('column')
    column.getDisplayName().then (columnName) => @set {columnName}
    column.model.makePath(type).getDisplayName().then (typeName) => @set {typeName}

  defaults: ->
    selected: false
    selectable: true

  toJSON: -> _.extend super, entity: @get('entity').toJSON()
