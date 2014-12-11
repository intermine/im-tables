require './shim'

{Service} = require 'imjs'
ConstraintAdder = require './views/constraint-adder'

conn = Service.connect root: 'http://localhost:8080/intermine-demo'

all_employees =
  select: ['name', 'age', 'department.name'],
  from: 'Employee'

renderQuery = (q) ->
  conAdder = new ConstraintAdder query: q
  conAdder.render().$el.appendTo document.getElementById 'demo'

conn.query(all_employees)
    .then renderQuery, (e) -> console.error e
