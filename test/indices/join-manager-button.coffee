QUERY = 
  name: 'Older employees'
  from: 'Department'
  select: [
    "company.name",
    "name",
    "employees.name",
    "employees.address.address",
  ]
  joins:
    company: 'OUTER'
  where: [
    {path: 'employees.age', op: '>', value: 30, editable: false}
    {path: 'employees.age', op: '<', value: 60}
  ]

$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'

# project code.
Button = require 'imtables/views/join-manager/button'
# test code.
SelectionTable = require '../lib/selection-table'
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'

create = (query) ->
  table = new SelectionTable query: query, model: (new Backbone.Model)
  table.render().$el.appendTo 'body'

  new Button {query}

renderQuery = renderWithCounter create

$ -> renderQueries [QUERY], renderQuery
