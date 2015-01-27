Backbone = require 'backbone'

EVTS = 'change:constraints change:views change:sortorder change:joins change:logic'

module.exports = class XMLDisplay extends Backbone.View

  tagName: 'pre'

  initialize: ({query}) ->
    @setQuery query if query?

  setQuery: (query) ->
    hadQuery = @query?
    @stopListening @query if hadQuery
    @query = query
    @listenTo query, EVTS, @render
    @render() if hadQuery

  render: ->
    @$el.text @query?.toXML()
    this
