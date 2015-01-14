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

ModelDisplay = require '../lib/model-display.coffee'
CoreModel = require 'imtables/core-model'
NumericRange = require 'imtables/models/numeric-range'
SummaryItems = require 'imtables/models/summary-items'
SummaryStats = require 'imtables/views/facets/summary-stats'
SummaryHeading = require 'imtables/views/facets/summary-heading'
NumericDistribution = require 'imtables/views/facets/numeric'

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
  distribution = new NumericDistribution {model, range}
  stats = new SummaryStats {model, range}
  heading = new SummaryHeading {model, state}

  renderModelDisplays display, state_display, range_display

  renderAll container, [heading, distribution, stats]

renderModelDisplays = (views...) ->
  width = (100 / views.length)
  for view, i in views
    isLast = (i + 1 is views.length)
    css =
      position: 'fixed'
      width: "#{ width.toFixed(2) }%"
      bottom: 0,
      'font-size': '12px'

    if isLast
      css.right = 0
    else
      css.left = "#{ (i * width).toFixed(2) }%"

    view.render()
    view.$el.css css
            .appendTo 'body'
      

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
