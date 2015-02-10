CoreModel = require '../core-model'

# FastPathObjects are light-weight data-base objects that
# don't have ids. Because of this we can't merge them or
# link to report pages or show previews.
module.exports = class FPObject extends CoreModel

  constructor: (obj, field) ->
    super()
    @set
      'id': null
      'class': obj.class
      'service:base': ''
      'service:url': ''
      'report:uri': null
    @set field, obj.value

