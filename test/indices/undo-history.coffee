$ = require 'jquery'
Backbone = require 'backbone'
# project code.
Button = require 'imtables/views/undo-history'
History = require 'imtables/models/history'
# test code.
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'
SelectionTable = require '../lib/selection-table'
XMLDisplay = require '../lib/xml-display'

done = console.log.bind(console, 'SUCCESS')
fail = console.error.bind(console)
onChangeRevision = (s) ->
  console.log "Current state is now revision #{ s.get 'revision' }"

create = (query) ->
  xmlDisplay = new XMLDisplay {query} 
  xmlDisplay.render().$el.appendTo 'body'

  table = new SelectionTable model: (new Backbone.Model)
  table.render().$el.appendTo 'body'

  history = new History
  history.setInitialState query

  history.on 'changed:current', onChangeRevision
  history.on 'changed:current', (state) ->
    table.setQuery state.get 'query'
    xmlDisplay.setQuery state.get 'query'

  history.getCurrentQuery().addToSelect 'employees.age'
  history.getCurrentQuery().addToSelect 'employees.end'
  history.getCurrentQuery().orderBy ['name']
  history.getCurrentQuery().addSortOrder 'employees.name'
  history.getCurrentQuery().addConstraint ['employees.age', '<', 60]

  new Button {collection: history}

renderQuery = renderWithCounter create

queries = [ # We are creating a query here just for its service, oh, and its table.
  {
    from: 'Department'
    select: ["company.name", "name", "employees.name"]
    where: [ ['employees.age', '>', 30] ]
  }
]

$ -> renderQueries queries, renderQuery
