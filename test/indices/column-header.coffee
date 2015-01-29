$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'

HeaderModel = require 'imtables/models/header'
ColumnHeader = require 'imtables/views/table/header'

renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'

class Headers extends Backbone.Collection

  model: HeaderModel

class BasicTable extends Backbone.View

  tagName: 'table'

  className: 'table table-striped'

  initialize: ({@query}) ->
    @headers = new Headers
    for v in @query.views
      @headers.add path: @query.makePath v

  render: ->
    @$el.html '<thead><tr></tr></thead>'
    head = @$ 'thead tr'
    @headers.each (model) =>
      h = new ColumnHeader {model, @query}
      h.appendTo head
      h.render()
    this

create = (query) -> return new BasicTable {query}

queries = [
  {
    name: "older than 35"
    select: ["name", "company.name", "manager.name", "employees.age"]
    from: "Department"
    where: [ [ "employees.age", ">", 35 ] ]
  }
]

renderQuery = renderWithCounter create

$ -> renderQueries queries, renderQuery
