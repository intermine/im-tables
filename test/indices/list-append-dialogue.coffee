queries = [
  {
    name: "older than 35"
    select: ["name", "manager.name", "employees.name", "employees.age"]
    from: "Department"
    where: [ [ "employees.age", ">", 35 ] ]
  }
]

Dialogue = require 'imtables/views/list-dialogue/append-from-path'

ListAppendFramework = require '../lib/list-append-framework.coffee'

ListAppendFramework.runWithQuery queries, (query) -> new Dialogue {query, path: 'employees.id'}
