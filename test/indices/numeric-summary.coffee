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

{renderModelDisplays, ModelDisplay} = require '../lib/model-display.coffee'

# Models
CoreModel = require 'imtables/core-model'
NumericRange = require 'imtables/models/numeric-range'
SummaryItems = require 'imtables/models/summary-items'
# Views
FacetItems = require 'imtables/views/facets/items'
SummaryHeading = require 'imtables/views/facets/summary-heading'
NumericDistribution = require 'imtables/views/facets/numeric'
FacetVisualisation = require 'imtables/views/facets/visualisation'

root = "http://localhost:8080/intermine-demo"
conn = imjs.Service.connect(root: root)

renderQuery = (container, query) ->
  # These are the things that need doing.
  model = new SummaryItems {query, view: query.makePath('employees.age')}
  range = new NumericRange
  state = new CoreModel
  model.on 'change:min change:max', -> range.setLimits model.pick 'min', 'max'

  # These display the data on the bottom of the screen.
  display = new ModelDisplay {model: model}
  range_display = new ModelDisplay {model: range}
  state_display = new ModelDisplay {model: state}

  # This is what we actually care about.
  heading = new SummaryHeading {model, state}
  viz = new FacetVisualisation {model, range}
  stats = new FacetItems {model, range}

  renderModelDisplays display, state_display, range_display

  renderAll container, [heading, viz, stats]

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
