Backbone = require 'backbone'
CoreModel = require '../core-model'

# Clean up models on destruction.
module.exports = class CoreCollection extends Backbone.Collection

  model: CoreModel

  close: ->
    @trigger 'close'
    while m = @pop()
      if m.collection is @
        delete m.collection
        m.destroy()
    @reset()
    @off()
    @stopListening()
