queries = [ # We are creating a query here just for its service, oh, and its table.
  { select: ["Department.name", "Department.employees.name"] }
]

# project code.
Dialogue = require 'imtables/views/list-dialogue/append-from-selection'
Collection = require 'imtables/core/collection'
# test code.
ListAppendFramework = require '../lib/list-append-framework'
renderItemSelector = require '../lib/item-selector'

objects = new Collection

create = (query) ->
  renderItemSelector query, 1, objects
  new Dialogue {collection: objects, service: query.service}

ListAppendFramework.runWithQuery queries, create, ['model', 'state', 'collection', 'possibleLists']
