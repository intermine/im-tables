$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'

CoreModel = require 'imtables/core-model'
CoreView = require 'imtables/core-view'
Options = require 'imtables/options'
HeaderModel = require 'imtables/models/header'
ColumnHeader = require 'imtables/views/table/header'

renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'

class Headers extends Backbone.Collection

  model: HeaderModel

class BasicTable extends CoreView

  tagName: 'table'

  className: 'table table-striped'

  initialize: ({@query}) ->
    super
    @headers = new Headers
    @setHeaders()
    @listenTo @query, 'change:views', @setHeaders
    @listenTo @headers, 'add remove', @render
    @listenTo @headers, 'remove', (m) -> m.destroy()

  setHeaders: ->
    hds = for v in @query.views
      new HeaderModel {path: @query.makePath v}, @query
    @headers.set hds

  template: -> '<thead><tr></tr></thead>'

  postRender: ->
    head = @$ 'thead tr'
    @headers.each (model) =>
      console.log 'rendering', model.id
      @renderChild model.id, (new ColumnHeader {model, @query}), head
    this

Options.set 'ModelDisplay.Initially.Closed', true

create = (query) -> return new BasicTable {query}

queries = [
  {
    name: "older than 35"
    select: ["name", "company.name", "manager.name", "employees.age"]
    from: "Department"
    where: [ [ "employees.age", ">", 35 ] ]
    orderBy: [ ['name', 'DESC'] ]
  }
]

renderQuery = renderWithCounter create, (->), ['headers']

$ -> renderQueries queries, renderQuery
