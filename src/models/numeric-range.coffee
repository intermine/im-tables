_ = require 'underscore'
Backbone = require 'backbone'

# Not at all sure if this class is necessary, or at least if the way
# it manages its defaults isn't a little silly. On the other hand, it
# works, so there is that.
module.exports = class NumericRange extends Backbone.Model

  _defaults: {}

  setLimits: (limits) -> _.extend @_defaults, limits

  get: (prop) ->
    ret = super(prop)
    if ret?
      ret
    else if prop of @_defaults
      @_defaults[prop]
    else
      null

  toJSON: -> _.extend {}, @_defaults, @attributes

  nullify: ->
    @unset 'min'
    @unset 'max'
    @nulled = true
    @trigger evt, @ for evt in ['change:min', 'change:max', 'change']

  reset: ->
    @clear()
    @trigger 'reset', @

  set: (name, value) ->
    @nulled = false
    if _.isString(name) and (name of @_defaults)
      meth = if name is 'min' then 'max' else 'min'
      super(name, Math[meth](@_defaults[name], value))
    else
      super(arguments...)

  isNotAll: ->
    return false if @nulled
    {min, max} = @toJSON()
    (min? and min isnt @_defaults.min) or (max? and max isnt @_defaults.max)

