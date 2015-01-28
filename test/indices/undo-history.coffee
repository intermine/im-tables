$ = require 'jquery'
_ = require 'underscore'
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

# Our history of query states.
history = new History

playBackHistory = ->
  history.getCurrentQuery().orderBy ['name']
  history.getCurrentQuery().addToSelect ['employees.name', 'employees.age']
  history.getCurrentQuery().addConstraint ['name', '=', 'S*']
  history.getCurrentQuery().addToSelect 'employees.end'
  history.getCurrentQuery().addSortOrder 'employees.name'
  history.getCurrentQuery().removeFromSelect 'employees.age'
  q6 = history.getCurrentQuery() # Rearranged view
  q6.select _.shuffle q6.views
  history.getCurrentQuery().addConstraint ['employees.age', '<', 60]
  q8 = history.getCurrentQuery() # Changed sort order
  q8.addOrSetSortOrder path: 'name', direction: 'DESC'

create = (query, counter) ->
  history.setInitialState query

  xmlDisplay = new XMLDisplay {query} 
  xmlDisplay.render().$el.appendTo 'body'

  table = new SelectionTable model: (new Backbone.Model)
  table.render().$el.appendTo 'body'

  history.on 'changed:current', onChangeRevision
  history.on 'changed:current', (state) ->
    table.setQuery state.get 'query'
    xmlDisplay.setQuery state.get 'query'
    counter.setQuery state.get 'query'

  # Simulate a sequence of actions over a history of query states.
  playBackHistory()

  new Button {collection: history}

renderQuery = renderWithCounter create

queries = [ # We are creating a query here just for its service, oh, and its table.
  {
    name: 'History query'
    from: 'Department'
    select: ["company.name", "name"]
    where: [ ['employees.age', '>', 30] ]
  }
]

$ -> renderQueries queries, renderQuery
