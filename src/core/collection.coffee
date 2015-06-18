Backbone = require 'backbone'
CoreModel = require '../core-model'

# Clean up models on destruction.
module.exports = class CoreCollection extends Backbone.Collection

  model: CoreModel

  add: ->
    console.log "Collection calling base add"
    super

  close: ->
    @trigger 'close', @
    @off() # prevent trigger loops.
    while m = @pop()
      if m.collection is @
        delete m.collection
        m.destroy()
    @reset()
    @stopListening()
