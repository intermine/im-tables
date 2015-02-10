CoreModel = require '../core-model'

module.exports = class NullObject extends CoreModel

  constructor: (type, field) ->
    super()
    @set
      'id': null
      'isNULL': true
      'class': type
      'service:base': ''
      'service:url': ''
      'report:uri': null
    @set field, null if field

