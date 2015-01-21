queries = [ # We are creating a query here just for its service, oh, and its table.
  { select: ["Department.name", "Department.employees.name"] }
]

require 'imtables/shim'
$ = require 'jquery'

Collection = require 'imtables/core/collection'
Dialogue = require 'imtables/views/list-dialogue/create-from-selection'

objects = new Collection

renderQueries = require '../lib/render-queries.coffee'
renderQueryWithCounter = require '../lib/render-query-with-counter-and-displays.coffee'
renderItemSelector = require '../lib/item-selector'

fail = console.error.bind(console)
done = (res) ->
  return console.log('dialogue dismissed - no list created') if res is 'dismiss'
  list = res
  console.log 'SUCCESS - created', list
  list.del()
      .then -> console.log 'Cleaned up ', list.name
      .then null, (e) -> console.error "Failed to delete #{ list.name }", e

create = (query) ->
  renderItemSelector query, 1, objects
  new Dialogue {collection: objects, service: query.service}

showDialogue = (dialogue) -> dialogue.show().then done, fail

renderQuery = renderQueryWithCounter create, showDialogue

$ -> renderQueries queries, renderQuery, authed = true
