IMObject = require './intermine-object'

module.exports = class FPObject extends IMObject

  constructor: (obj, field) ->
    @set
      'id': null
      'class': obj.class
      'service:base': ''
      'service:url': ''
    @set field, obj.value

