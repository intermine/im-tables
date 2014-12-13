require './shim'

{Service} = require 'imjs'
NewFilterDialogue = require './views/new-filter-dialogue'

conn = Service.connect root: 'http://localhost:8080/intermine-demo'

all_employees =
  select: ['name', 'age', 'department.name'],
  from: 'Employee'

renderQuery = (q) ->
  dialogue = new NewFilterDialogue query: q
  dialogue.$el.appendTo '#demo'
  dialogue.render()
  dialogue.show()

conn.query(all_employees)
    .then(renderQuery)
    .then null, (e) -> console.error e
