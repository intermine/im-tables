_ = require 'underscore'
CoreModel = require '../core-model'

# The data fields are separated from meta-data
# by using colons in their field names, which are illegal data field name characters.
module.exports = class IMObject extends CoreModel

  # @param base [String] the base URL
  # @param type [PathInfo] The type of this entity.
  # @param id [any] the (opaque) id of this entity.
  constructor: (base, type, id) ->
    super class: String(type), id: id # set identifying values.
    @type = type
    @set 'service:base': base
    @freeze 'id', 'class' # Do not allow these properties to change.

  toJSON: ->
    url = @get 'service:url'
    uri = if (/^http/.test url)
      url
    else
      @get('service:base') + url
    _.extend super, 'report:uri': uri

  merge: (obj, field) ->
    @set field, obj.value
    @set 'service:url': obj.url

