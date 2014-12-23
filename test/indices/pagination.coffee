"use strict"

require "imtables/shim"
_ = require 'underscore'
{Model, View} = require 'backbone'
$ = require("jquery")
imjs = require("imjs")

print = console.log.bind console
printErr = console.error.bind console

Pagination = require 'imtables/views/table/pagination'
PageSizer = require 'imtables/views/table/page-sizer'

ModelDisplay = require '../lib/model-display.coffee'

models = [
  {start: 0, size: 10, count: 100},
  {start: 10, size: 10, count: 10000},
  {start: 25, size: 5, count: 50}
]

$ ->
  container = document.querySelector("#demo")

  for m in models
    div = document.createElement("div")
    h2 = document.createElement("h2")
    container.appendChild div
    div.appendChild h2
    model = new Model m

    md = new ModelDisplay model: model
    md.$el.appendTo h2

    pageSizer = new PageSizer model: model
    pageSizer.$el.appendTo div

    paginator = new Pagination model: model
    paginator.$el.appendTo div

    md.render()
    pageSizer.render()
    paginator.render()
