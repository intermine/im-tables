"use strict"

queries = [
  {
    name: "older than 35"
    select: [
      "name"
      "age"
      "department.name"
      "department.manager.name"
    ]
    from: "Employee"
    where: [
      [ "age", ">", 35 ]
    ]
  }
]

require "imtables/shim"
$ = require "jquery"
imjs = require "imjs"

Dialogue = require("imtables/views/export-dialogue")

Counter = require('../lib/counter.coffee')
ModelDisplay = require '../lib/model-display.coffee'

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (heading, container, query) ->
  counter = new Counter el: heading, query: query
  counter.render()
  dialogue = new Dialogue {query}
  display = new ModelDisplay {model: dialogue.model}
  display.render()
  display.$el.css position: 'fixed', bottom: 0, 'font-size': '12px'
             .appendTo 'body'
  dialogue.$el.appendTo container
  dialogue.render()
  dialogue.show().then console.log.bind(console, 'SUCCESS'), console.error.bind(console)

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
