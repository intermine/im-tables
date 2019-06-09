_ = require 'underscore'
Backbone = require 'backbone'

exports.ignore = (e) ->
  e?.preventDefault()
  e?.stopPropagation()
  return false

class exports.Bus

  _.extend @.prototype, Backbone.Events

  destroy: ->
    @stopListening()
    @off()
