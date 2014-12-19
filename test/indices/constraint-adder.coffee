"use strict"

require "imtables/shim"
_ = require 'underscore'
{Events} = require 'backbone'
$ = require("jquery")
imjs = require("imjs")

print = console.log.bind console
printErr = console.error.bind console

ConstraintAdder = require("imtables/views/constraint-adder")
Counter = require('../lib/counter.coffee')

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (heading, container, query) ->
  _.extend query, Events # oops. We will need to fix this at the query level.
  counter = new Counter el: heading, query: query
  counter.render()
  addConstraint = ->
    view = new ConstraintAdder {query}
    view.$el.appendTo container
    print container
    view.render()
  query.on 'change:constraints', ->
    btn = document.createElement 'button'
    btn.className = 'btn btn-primary btn-lg'
    btn.innerHTML = 'Add another constraint'
    container.appendChild btn
    btn.onclick = ->
      container.removeChild btn
      addConstraint()
  addConstraint()

$ ->
  container = document.querySelector("#demo")
  query =
    name: 'Employees and their department'
    from: 'Employee'
    select: ['name', 'department.name']

  div = document.createElement("div")
  h2 = document.createElement("h2")
  container.appendChild div
  h2.innerHTML = query.name
  div.appendChild h2
  conn.query(query)
      .then renderQuery.bind(null, h2, div)
      .then print.bind(null, 'rendered'), printErr.bind(null, "Could not render query")
