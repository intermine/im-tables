_ = require 'underscore'

doc = global.document
onError = (q, e) -> console.error "Could not render query", q, e

module.exports = (renderQuery, connection, query, container) ->
  container ?= doc.querySelector('#demo')
  div = doc.createElement("div")
  h2 = doc.createElement("h2")

  container.appendChild div
  h2.innerHTML = query.name
  div.appendChild h2

  connection.query query
            .then _.partial renderQuery, h2, div
            .then null, _.partial onError, query

