CoreModel = require '../core-model'

{Model: {NUMERIC_TYPES, BOOLEAN_TYPES}} = require 'imjs'

module.exports = class PathModel extends CoreModel

  defaults: ->
    path: null
    type: null
    displayName: null
    typeName: null
    parts: []
    isNumeric: false
    isBoolean: false

  constructor: (path) ->
    super()
    str = String path
    @set
      id: (if path.isAttribute() then str else "#{ str }.id")
      path: str
      type: path.getType().name

    type = (if path.isAttribute() then path.getParent() else path).getType()
    path.getDisplayName().then (name) =>
      @set displayName: name, parts: name.split(' > ')
    type.getDisplayName().then (name) =>
      @set typeName: name

    if path.isAttribute()
      atype = path.getType()
      if atype in NUMERIC_TYPES
        @set isNumeric: true
      else if atype in BOOLEAN_TYPES
        @set isBoolean: true
