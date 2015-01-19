queries = [ # We are creating a query here just for its service.
  { select: ["Department.name"] }
]

require 'imtables/shim'
$ = require 'jquery'

Collection = require 'imtables/core/collection'
Dialogue = require 'imtables/views/list-picker-dialogue'

objects = new Collection

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

# There are better ways to lay our hands on a service, really.
create = (query) -> new Dialogue {collection: objects, service: query.service}
showDialogue = (dialogue) -> dialogue.show().then done, fail

renderQuery = renderQueryWithCounter create, showDialogue

$ -> renderQueries queries, renderQuery, authed = true
