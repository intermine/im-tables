Backbone = require 'backbone'
_ = require 'underscore'

IMObject = require './intermine-object'

module.exports = class ObjectStore

  constructor: (@query) ->
    @base = @query.service.root.replace /\/service\/?$/, ""
    @_objects = {}

  get: (obj, field) ->
    model = (@_objects[obj.id] ?= new IMObject @query, @base)
    model.merge obj, field
    return model

  destroy: ->
    for id, model of @_objects
      model.destroy()
    delete @objects
    delete @query

_.extend ObjectStore.prototype, Backbone.Events
