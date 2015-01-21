queries = [ # We are creating a query here just for its service, oh, and its table.
  {
    from: 'Department'
    select: ["company.name", "name", "employees.name"]
    where: [ ['employees.age', '>', 30] ]
  }
]

# project code.
Button = require 'imtables/views/list-dialogue/button'
Collection = require 'imtables/core/collection'
# test code.
ListAppendFramework = require '../lib/list-append-framework'
SelectionTable = require '../lib/selection-table'

objects = new Collection

create = (query) ->
  table = new SelectionTable {query, selected: objects}
  table.render().$el.appendTo 'body'

  new Button {query: query}

ListAppendFramework.runWithQuery queries, create, ['model', 'state'], (->)
