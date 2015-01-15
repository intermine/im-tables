"use strict"

require "imtables/shim"
_ = require 'underscore'
imjs = require "imjs"

{displayModels, ModelDisplay} = require './model-display.coffee'

# views
FacetView = require 'imtables/views/facets/facet-view'

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (container, path, q) ->
  # the view we are testing.
  facet = new FacetView {query: q, view: q.makePath(path)}

  # display the data on the bottom of the screen.
  displayModels facet, ['model', 'range', 'state']

  renderAll container, [facet]

renderAll = (container, views) ->
  for view in views
    view.$el.appendTo container
    view.render()

onError = (q, e) ->
  console.log "Could not render query", q, (e.stack ? e)

module.exports = (query, path) ->
  container = document.querySelector("#demo")
  div = document.createElement("div")
  container.appendChild div
  conn.query(query)
      .then renderQuery.bind(null, div, path)
      .then null, _.partial onError, query

