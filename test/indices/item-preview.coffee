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
  Employee: [{label: 'Colleagues', query: colleaguesQuery}]

Options.set ['Preview', 'Count', connection.root], opts

main = ->
  findAndRender 'Employee', 'David Brent'
  findAndRender 'Company', 'Wernham-Hogg'

findAndRender = (type, name) -> fetchId(find type, name).then renderPreview type

fetchId = (query) -> connection.rows(query).then ([[id]]) -> id

find = (type, name) ->
  select: ['id']
  from: type
  where: {name}

createPanel = ->
  p = document.createElement 'div'
  p.className = 'panel panel-default'
  b = document.querySelector 'body'
  b.appendChild p
  pbody = document.createElement 'div'
  pbody.className = 'panel-body'
  p.appendChild pbody
  return pbody

renderPreview = (type) -> (id) ->
  p = createPanel()

  view = new Preview service: connection, model: {id, type}
  p.appendChild view.render().el

$ main
