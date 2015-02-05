queries = [ # We are creating a query here just for its service, oh, and its table.
  {
    from: 'Department'
    select: ["company.name", "name", "employees.name"]
    where: [ ['employees.age', '>', 30] ]
  }
]

# project code.
Button = require 'imtables/views/list-dialogue/button'
SelectedObjects = require 'imtables/models/selected-objects'
# test code.
ListAppendFramework = require '../lib/list-append-framework'
SelectionTable = require '../lib/selection-table'

onListAppend = (res) ->
  ListAppendFramework.done(res).then ListAppendFramework.setup

onListCreate = (res) ->
  return console.log('dismissed') if res is 'dismiss'
  list = res
  list.del().then -> console.log 'cleaned up', list
            .then null, (e) -> console.error 'err', e

create = (query) ->
  objects = new SelectedObjects query.service

  table = new SelectionTable {query, selected: objects}
  table.render().$el.appendTo 'body'

  button = new Button {query: query, selected: objects}
  button.on 'list:append', onListAppend
  button.on 'list:create', onListCreate
  return button

ListAppendFramework.runWithQuery queries, create, ['model', 'state'], (->)
