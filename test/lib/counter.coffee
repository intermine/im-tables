View = require("imtables/core-view")
Model = require 'imtables/core-model'
Executor = require 'imtables/utils/count-executor'

class CountModel extends Model

  defaults: ->
    count: 0

module.exports = class Counter extends View

  Model: CountModel

  initialize: (opts) ->
    super()
    @setQuery opts.query

  modelEvents: ->
    'change:count': @render

  setQuery: (query) ->
    @stopListening @query if @query?
    @query = query
    @listenTo @query, "change:constraints", @updateCount
    @listenTo @query, "change:views", @updateCount
    @listenTo @query, "change:joins", @updateCount
    @updateCount()

  updateCount: ->
    Executor.count @query
            .then (c) => @model.set count: c
            .then null, console.error.bind console

  render: ->
    name = (@query.name ? 'Query')
    rows = @model.get("count")
    cons = @query.constraints.length
    @$el.empty().text "#{ name } (#{ rows } rows, #{ cons } constraints)"
    this

