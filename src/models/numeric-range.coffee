Backbone = require 'backbone'

module.exports = class NumericRange extends Backbone.Model

  _defaults: {}

  setLimits: (limits) -> @_defaults = limits

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
    @set {min: null, max: null}
    @nulled = true
    @trigger evt, @ for evt in ['change:min', 'change:max', 'change']

  set: (name, value) ->
    @nulled = false
    if _.isString(name) and (name of @_defaults)
      meth = if name is 'min' then 'max' else 'min'
      super(name, Math[meth](@_defaults[name], value))
    else
      super(arguments...)

  isNotAll: ->
    return true if @nulled
    {min, max} = @toJSON()
    (min? and min isnt @_defaults.min) or (max? and max isnt @_defaults.max)
