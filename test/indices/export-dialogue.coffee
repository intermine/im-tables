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
Dialogue = require("imtables/views/export-dialogue")

Counter = require('../lib/counter.coffee')
ModelDisplay = require '../lib/model-display.coffee'

# Suitable for localhost development.
Options.set 'Destination.Dropbox.Enabled', true
Options.set 'Destination.Drive.Enabled', true
Options.set
  auth:
    dropbox: 'gqr6vpcnp8rmhe5'
    drive: '325597969559-0h7jf8u9bsnb96q2uji5ee1r74vrngsu.apps.googleusercontent.com'

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (heading, container, query) ->
  counter = new Counter el: heading, query: query
  counter.render()
  dialogue = new Dialogue {query, model: {tablePage: {start: 20, size: 10}}}
  display = new ModelDisplay {model: dialogue.model}
  state_display = new ModelDisplay {model: dialogue.state}
  display.render()
  state_display.render()
  display.$el.css position: 'fixed', width: '50%', left: 0, bottom: 0, 'font-size': '12px'
             .appendTo 'body'
  state_display.$el.css position: 'fixed', width: '50%', right: 0, bottom: 0, 'font-size': '12px'
             .appendTo 'body'
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
