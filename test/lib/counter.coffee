View = require("imtables/core-view")

module.exports = Counter = View.extend

  initialize: (opts) ->
    View::initialize.apply this, arguments
    @query = opts.query
    @model.set count: 0
    @listenTo @query, "change:constraints", @updateCount
    @listenTo @query, "change:views", @updateCount
    @listenTo @model, "change", @render
    @updateCount()
    return

  updateCount: ->
    self = this
    @query.count().then (c) ->
      self.model.set count: c
      return

    return

  render: ->
    name = @query.name
    count = @model.get("count")
    @$el.empty().text "#{ name } (#{ count } rows, #{ @query.constraints.length } constraints)"
    return

