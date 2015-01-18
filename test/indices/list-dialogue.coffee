queries = [
  {
    name: "older than 35"
    select: ["name", "manager.name", "employees.name", "employees.age"]
    from: "Department"
    where: [ [ "employees.age", ">", 35 ] ]
  }
]

require 'imtables/shim'
$ = require 'jquery'

Dialogue = require 'imtables/views/list-dialogue'

renderQueries = require '../lib/render-queries.coffee'
renderQueryWithCounter = require '../lib/render-query-with-counter-and-displays.coffee'
done = console.log.bind(console, 'SUCCESS')
fail = console.error.bind(console)

create = (query) -> new Dialogue {query, path: 'employees.id'}
showDialogue = (dialogue) -> dialogue.show().then done, fail

renderQuery = renderQueryWithCounter create, showDialogue

$ -> renderQueries queries, renderQuery
