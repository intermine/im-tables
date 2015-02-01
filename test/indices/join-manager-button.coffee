QUERY = 
  name: 'Older employees'
  from: 'Department'
  select: [
    "company.name",
    "name",
    "employees.name",
    "employees.address.address",
  ]
  joins: ['company', 'employees.address']
  where: [
    {path: 'employees.age', op: '>', value: 30, editable: false}
    {path: 'employees.age', op: '<', value: 60}
  ]

$ = require 'jquery'
_ = require 'underscore'

# project code.
Button = require 'imtables/views/join-manager/button'
# test code.
XMLDisplay = require '../lib/xml-display'
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'

create = (query) ->
  display = new XMLDisplay query: query
  display.render().$el.appendTo 'body'

  new Button {query}

renderQuery = renderWithCounter create

$ -> renderQueries [QUERY], renderQuery
