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
fail = console.error.bind(console)
done = (res) ->
  return console.log('dialogue dismissed - no list created') if res is 'dismiss'
  list = res
  console.log 'SUCCESS - created', list
  list.del()
      .then -> console.log 'Cleaned up ', list.name
      .then null, (e) -> console.error "Failed to delete #{ list.name }", e

create = (query) -> new Dialogue {query, path: 'employees.id'}
showDialogue = (dialogue) -> dialogue.show().then done, fail

renderQuery = renderQueryWithCounter create, showDialogue

$ -> renderQueries queries, renderQuery, authed = true
