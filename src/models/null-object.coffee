IMObject = require './intermine-object'

module.exports = class NullObject extends IMObject

  constructor: (type, field) ->
    @set
      'id': null
      'class': type
      'service:base': ''
      'service:url': ''
    @set field, null if field

