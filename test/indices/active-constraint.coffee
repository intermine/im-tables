"use strict"

queries = [
  {
    name: 'ranges'
    select: [
      "name", "author.name"
    ]
    from: 'Chapter'
    where: [
      {
        path: 'textLocation'
        op: 'OVERLAPS'
        values: ['012743212:500..1000']
      }
    ]
  }
  {
    name: "attributes"
    select: [
      "name"
      "department.name"
      "department.manager.name"
    ]
    from: "Employee"
    where: [
      [ "name", "=", "d*" ]
      [ "age", ">", 35 ]
      [ "fullTime", "=", true ]
    ]
  }
  {
    name: "multivalue"
    select: [
      "name"
      "department.name"
      "department.manager.name"
    ]
    from: "Employee"
    where: [[ "name", "ONE OF", [
      "Anne"
      "Brenda"
      "Carol"
    ]]]
  }
  {
    name: "type constraints"
    select: ["name", "employees.name", "employees.seniority"]
    from: "Department"
    where: [
      path: "employees"
      type: "Manager"
    ]
  }
  {
    name: "type constraints, one only"
    select: [
      "name"
      "manager.name"
    ]
    from: "Department"
    where: [
      path: "manager"
      type: "CEO"
    ]
  }
  {
    name: "type constraints, bad"
    select: [
      "name"
      "manager.name"
    ]
    from: "Department"
    where: [
      path: "manager"
      type: "Wizard"
    ]
  }
  {
    name: "lookup"
    select: [
      "name"
      "department.name"
      "department.manager.name"
    ]
    from: "Employee"
    where: [[
      "department.manager"
      "lookup"
      "anne, brenda, carol"
    ]]
  }
  {
    name: "lists"
    select: [
      "name"
      "department.name"
      "department.manager.name"
    ]
    from: "Employee"
    where: [[
      "Employee"
      "IN"
      "My favourite employees"
    ]]
  }
  {
    name: "loops"
    select: [
      "name"
      "department.name"
      "department.manager.name"
    ]
    from: "Employee"
    where: [[
      "department.company.CEO"
      "="
      "Employee.department.manager"
    ]]
  }
]

require "imtables/shim"
$ = require("jquery")
imjs = require("imjs")

Options = require("imtables/options")
ActiveConstraint = require("imtables/views/active-constraint")

Counter = require('../lib/counter.coffee')

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (heading, container, query) ->
  counter = new Counter el: heading, query: query
  counter.render()
  for constraint in query.constraints
    view = new ActiveConstraint {query, constraint}
    view.$el.appendTo container
    view.render()

$ ->
  container = document.querySelector("#demo")
  queries.forEach (q) ->
    div = document.createElement("div")
    h2 = document.createElement("h2")
    container.appendChild div
    h2.innerHTML = q.name
    div.appendChild h2
    conn.query(q)
        .then renderQuery.bind(null, h2, div)
        .then null, console.error.bind(console, "Could not render query", q)
