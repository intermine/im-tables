IMObject = require './intermine-object'

module.exports = class NullObject extends IMObject

  initialize: (_, {query, field, type}) ->
    @set
      'id': null
      'obj:type': type
      'is:selected': false
      'is:selectable': false
      'is:selecting': false
      'service:base': ''
      'service:url': ''
    @set field, null if field

