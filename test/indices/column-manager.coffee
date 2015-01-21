require 'imtables/shim'
$ = require 'jquery'

Dialogue = require 'imtables/views/column-manager'

renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'

done = console.log.bind(console, 'SUCCESS')
fail = console.error.bind(console)

create = (query) -> new Dialogue {query}
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
