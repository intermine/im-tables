Backbone = require 'backbone'

invert = (x) -> not x

# Extension to Backbone.Model which adds some useful helpers
#  - @swap(key, (val) -> val) - replaces value with derived value
#  - @toggle(key) - Specialisation of swap for booleans.
module.exports = class CoreModel extends Backbone.Model

  destroyed: false

  # Helper to toggle the state of boolean value (using not)
  toggle: (key) -> @swap key, invert

  # Helper to change the value of an entry using a function.
  swap: (key, f) -> @set key, f @get key

  toJSON: -> if @destroyed then 'DESTROYED' else super

  # Release listeners in both directions, and delete
  # all instance properties.
  destroy: -> unless @destroyed # re-entrant.
    @stopListening()
    @destroyed = true
    @trigger 'destroy', @, @collection
    @trigger 'change'
    @off()
    for prop of @ # need to do this last of all.
      delete @[prop]

  _frozen: []

  _validate: (attrs, opts) ->
    for p in @_frozen when p of attrs
      throw new Error("#{ p } is frozen")
    super

  # Calls to set(prop) after freeze(prop) will throw.
  freeze: (properties...) ->
    @_frozen = @_frozen.concat properties
    this

