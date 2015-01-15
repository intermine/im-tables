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
Dialogue = require("imtables/views/code-gen-dialogue")

Counter = require('../lib/counter.coffee')
{displayModels} = require '../lib/model-display.coffee'

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (heading, container, query) ->
  counter = new Counter el: heading, query: query
  dialogue = new Dialogue {query, model: {lang: 'py'}}

  counter.render()
  displayModels dialogue, ['model', 'state'], false
  dialogue.$el.appendTo container
  dialogue.render()
  dialogue.show().then console.log.bind(console, 'SUCCESS'), console.error.bind(console)

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
