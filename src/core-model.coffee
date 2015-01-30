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
  # Unlike in the standard backboniverse, this does not
  # attempt to sync with anywhere.
  destroy: -> unless @destroyed # re-entrant.
    @stopListening()
    @destroyed = true
    @trigger 'destroy', @, @collection
    @_frozen = []
    @clear()
    @off()

  _frozen: []

  _validate: (attrs, opts) ->
    for p in @_frozen when (p of attrs) and (attrs[p] isnt @get p)
      msg = "#{ p } is frozen (trying to set it to #{ attrs[p] } - is #{ @get p })"
      if opts.merge
        console.log 'Ignoring merge: ' + msg
        attrs[p] = @get p # otherwise it will be overwritten.
      else
        throw new Error msg
    super

  # Calls to set(prop) after freeze(prop) will throw.
  freeze: (properties...) ->
    @_frozen = @_frozen.concat properties
    this

