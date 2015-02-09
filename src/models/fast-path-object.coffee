IMObject = require './intermine-object'

# FastPathObjects are light-weight data-base objects that
# don't have ids. Because of this we can't merge them or
# link to report pages or show previews.
module.exports = class FPObject extends IMObject

  constructor: (obj, field) ->
    @set
      'id': null
      'class': obj.class
      'service:base': ''
      'service:url': ''
    @set field, obj.value

