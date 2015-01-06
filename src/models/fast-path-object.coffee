IMObject = require './intermine-object'

module.exports = class FPObject extends IMObject

  initialize: (_, {query, obj, field}) ->
    @set
      'id': null
      'obj:type': obj.class
      'is:selected': false
      'is:selectable': false
      'is:selecting': false
      'service:base': ''
      'service:url': ''
    @set field, obj.value

