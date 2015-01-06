CoreModel = require '../core-model'

# Forms a pair with ./nested-table
module.exports = class CellModel extends CoreModel

  initialize: ->
    type = @get('cell').get('obj:type')
    @get('column').getDisplayName().then (columnName) => @set {columnName}
    @get('query').model.makePath(type).getDisplayName().then (typeName) => @set {typeName}

