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

flatMap = (coll, f) -> _.flatten (_.map coll, f), shallow = true

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
    paths = (@query.makePath v for v in @query.views)
    byNode = _.groupBy paths, (p) -> p.getParent().toString()
    hds = _.map byNode, (viewPaths, nodePath) =>
      console.log nodePath, viewPaths.length
      if viewPaths.length is 1
        new HeaderModel {path: viewPaths[0]}, @query
      else
        node = @query.makePath nodePath
        new HeaderModel {path: node, replaces: viewPaths}, @query
    console.log(m.get 'path' for m in hds)
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
    select: [
      "name",
      "manager.name",
      "employees.name",
      "employees.age",
      "company.name",
    ]
    from: "Department"
    where: [
      [ "employees.age", ">", 35 ],
      [ 'name', 'ONE OF', [
        'Accounting',
        'Board of Directors',
        'Kantine',
        'Sales',
        'Verwaltung'
        'Warehouse',
      ]]
    ]
    orderBy: [ ['name', 'DESC'] ]
  }
]

renderQuery = renderWithCounter create, (->), ['headers']

$ -> renderQueries queries, renderQuery
