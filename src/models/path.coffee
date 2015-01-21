CoreModel = require '../core-model'

module.exports = class PathModel extends CoreModel

  defaults: ->
    path: null
    type: null
    displayName: null
    typeName: null

  constructor: (path) ->
    super()
    str = String path
    @set
      id: (if path.isAttribute() then str else "#{ str }.id")
      path: str
      type: path.getType().name

    type = (if path.isAttribute() then path.getParent() else path).getType()
    path.getDisplayName().then (name) =>
      @set displayName: name
    type.getDisplayName().then (name) =>
      @set typeName: name
