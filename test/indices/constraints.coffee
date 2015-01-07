"use strict"

queries = [
  {
    name: "older than 35"
    select: [
      "name"
      "manager.name"
      "employees.name"
      "employees.age"
    ]
    from: "Department"
    where: [
      [ "employees.age", ">", 35 ]
    ]
  }
]

require "imtables/shim"
$ = require "jquery"
_ = require 'underscore'
imjs = require "imjs"

Options = require 'imtables/options'

Counter = require('../lib/counter.coffee')
ModelDisplay = require '../lib/model-display.coffee'
Constraints = require 'imtables/views/constraints'

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (heading, container, query) ->
  counter = new Counter el: heading, query: query
  counter.render()
  constraints = new Constraints {query}
  display = new ModelDisplay {model: constraints.model}
  state_display = new ModelDisplay {model: constraints.state}
  display.render()
  state_display.render()
  display.$el.css position: 'fixed', width: '50%', left: 0, bottom: 0, 'font-size': '12px'
             .appendTo 'body'
  state_display.$el.css position: 'fixed', width: '50%', right: 0, bottom: 0, 'font-size': '12px'
             .appendTo 'body'
  constraints.$el.appendTo container
  constraints.render()

onError = (q, e) ->
  console.log "Could not render query", q, (e.stack ? e)

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
        .then null, _.partial onError, q
