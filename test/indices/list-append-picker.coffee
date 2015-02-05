queries = [ # We are creating a query here just for its service, oh, and its table.
  { select: ["Department.name", "Department.employees.name"] }
]

# project code.
Dialogue = require 'imtables/views/list-dialogue/append-from-selection'
SelectedObjects = require 'imtables/models/selected-objects'
# test code.
ListAppendFramework = require '../lib/list-append-framework'
renderItemSelector = require '../lib/item-selector'

create = (query) ->
  objects = new SelectedObjects query.service
  renderItemSelector query, 1, objects
  new Dialogue {collection: objects, service: query.service}

ListAppendFramework.runWithQuery queries, create, ['model', 'state', 'collection', 'possibleLists']
