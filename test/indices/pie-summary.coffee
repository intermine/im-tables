"use strict"

queries = [
  {
    name: "older than 35"
    select: [
      "name"
      "age"
      "department.name"
      "department.company.name"
    ]
    from: "Employee"
    where: [
      [ "age", ">", 35 ]
    ]
  }
]

require "imtables/shim"
$ = require "jquery"
_ = require 'underscore'
imjs = require "imjs"

{renderModelDisplays, ModelDisplay} = require '../lib/model-display.coffee'
CoreModel = require 'imtables/core-model'

# Models
SummaryItems = require 'imtables/models/summary-items'
NumericRange = require 'imtables/models/numeric-range'

# views
SummaryHeading = require 'imtables/views/facets/summary-heading'
FacetVisualisation = require 'imtables/views/facets/visualisation'
FacetItems = require 'imtables/views/facets/items'

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (container, query) ->
  # These are the things that need doing.
  model = new SummaryItems {query, view: query.makePath('department.company.name')}
  range = new NumericRange
  state = new CoreModel
  model.on 'change:min change:max', -> range.setLimits model.pick 'min', 'max'

  # These display the data on the bottom of the screen.
  display = new ModelDisplay {model: model}
  state_display = new ModelDisplay {model: state}

  # This is what we actually care about.
  items = new FacetItems {model, state}
  vis = new FacetVisualisation {model, state, range}
  heading = new SummaryHeading {model, state}

  renderModelDisplays display, state_display

  renderAll container, [heading, vis, items]

renderAll = (container, views) ->
  for view in views
    view.$el.appendTo container
    view.render()

onError = (q, e) ->
  console.log "Could not render query", q, (e.stack ? e)

$ ->
  container = document.querySelector("#demo")
  queries.forEach (q) ->
    div = document.createElement("div")
    container.appendChild div
    conn.query(q)
        .then renderQuery.bind(null, div)
        .then null, _.partial onError, q
