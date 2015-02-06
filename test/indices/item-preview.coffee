"use strict"

$ = require "jquery"
{connection} = require '../lib/connect-to-service'

Preview = require 'imtables/views/item-preview'
Options = require 'imtables/options'

colleaguesQuery = (id) ->
  from: 'Employee'
  select: 'department.employees.id'
  where: [
    ['id', '=', id],
    ['department.employees.id', '!=', id]
  ]

opts =
  Department: ['employees']
  Employee: [{label: 'colleagues', query: colleaguesQuery}]

Options.set ['Preview', 'Count', connection.root], opts

query =
 select: ['id']
 from: 'Employee'
 where: {name: 'David Brent'}

main = ->
  connection.rows query
            .then ([[id]]) -> id
            .then renderPreview

renderPreview = (id) ->
  view = new Preview service: connection, model: {id, type: 'Employee'}
  view.render().$el.appendTo 'body'

$ main
