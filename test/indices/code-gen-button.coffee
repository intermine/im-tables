"use strict"

queries = [
  {
    name: "older than 35"
    select: ["name", "manager.name", "employees.name", "employees.age"]
    from: "Department"
    where: [ [ "employees.age", ">", 35 ] ]
  }
]

require "imtables/shim"
$ = require "jquery"

Button = require 'imtables/views/code-gen-button'

renderQueries = require '../lib/render-queries.coffee'
renderQueryWithCounter = require '../lib/render-query-with-counter-and-displays.coffee'

renderQuery = renderQueryWithCounter (query) -> new Button {query}

$ -> renderQueries queries, renderQuery
