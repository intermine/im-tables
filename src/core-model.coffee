Backbone = require 'backbone'

invert = (x) -> not x

# Extension to Backbone.Model which adds some useful helpers
#  - @swap(key, (val) -> val) - replaces value with derived value
#  - @toggle(key) - Specialisation of swap for booleans.
module.exports = class CoreModel extends Backbone.Model

  # Helper to toggle the state of boolean value (using not)
  toggle: (key) -> @swap key, invert

  # Helper to change the value of an entry using a function.
  swap: (key, f) -> @set key, f @get key

  # Release listeners in both directions, and delete
  # all instance properties.
  destroy: ->
    @stopListening()
    @off()
    for prop of @
      delete @[prop]
