_ = require 'underscore'

IMObject = require './intermine-object'

# A simple class to cache object construction, guaranteeing there is only ever one
# entity object for each entity. It also manages merging in the properties of the
# entities when multiple fields have been selected.
# 
# This means that a query that selects Employee.name and Employee.age will only have
# one Employee entity per employee object (keyed by id), and each object will have the
# appropriate `name` and `age` fields.
module.exports = class ObjectStore

  constructor: (root, @schema) ->
    throw new Error('No root') unless root?
    throw new Error('no schema') unless @schema?
    @base = root.replace /\/service\/?$/, "" # trim the /service
    @_objects = {}

  get: (obj, field) ->
    model = (@_objects[obj.id] ?= @_newObject obj)
    model.merge obj, field
    return model

  _newObject: (obj) ->
    classes = (@schema.makePath c for c in (obj['class']?.split(',') ? []))
    new IMObject @base, classes, obj.id

  destroy: ->
    for id, model of @_objects
      model.destroy()
    delete @selectedObjects
    delete @_objects

