_ = require 'underscore'
CoreModel = require '../core-model'
Executor = require '../utils/count-executor'

# A model that captures the state of a moment in the history.
# It maintains the count of the query through a caching executor,
# and records the time it was created.
module.exports = class StepModel extends CoreModel

  defaults: ->
    count: 0

  initialize: ->
    super
    @set createdAt: (new Date())
    @listenTo @, 'change:query', @_setCount
    @_setCount()

  _setCount: ->
    q = @get 'query'
    if q?
      Executor.count(q).then (c) => @set count: c
    else
      @set count: 0

  toJSON: -> _.extend super, query: @get('query').toJSON()

