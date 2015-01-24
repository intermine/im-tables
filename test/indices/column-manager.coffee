require 'imtables/shim'
$ = require 'jquery'
Backbone = require 'backbone'

Dialogue = require 'imtables/views/column-manager'

renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'
SelectionTable = require '../lib/selection-table'

done = console.log.bind(console, 'SUCCESS')
fail = console.error.bind(console)

create = (query) ->
  table = new SelectionTable {query, model: new Backbone.Model}
  table.render().$el.appendTo 'body'
  new Dialogue {query}
showDialogue = (dialogue) -> dialogue.show().then done, fail

queries = [
  {
    name: "older than 35"
    select: ["name", "manager.name", "employees.name", "employees.age"]
    from: "Department"
    where: [ [ "employees.age", ">", 35 ] ]
  }
]

renderQuery = renderWithCounter create, showDialogue

$ -> renderQueries queries, renderQuery
