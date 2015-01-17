Backbone = require 'backbone'
CoreModel = require '../core-model'

# Clean up models on destruction.
module.exports = class CoreCollection extends Backbone.Collection

  model: CoreModel

  close: ->
    @trigger 'close'
    @each (m) => m.destroy() if m.collection is @
    @reset()
    @off()
    @stopListening()
