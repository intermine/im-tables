_ = require 'underscore'
imjs = require "imjs"

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

onError = (q, e) ->
  console.log "Could not render query", q, (e.stack ? e)

module.exports = (queries, renderQuery, authed = false) ->
  c = conn.connectAs if authed then 'test-user-token' else null
  container = document.querySelector("#demo")
  queries.forEach (q) ->
    div = document.createElement("div")
    h2 = document.createElement("h2")
    container.appendChild div
    h2.innerHTML = q.name
    div.appendChild h2
    c.query(q)
     .then renderQuery.bind(null, h2, div)
     .then null, _.partial onError, q

