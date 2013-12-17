NullObject = require './null-object'

class FPObject extends NullObject

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
