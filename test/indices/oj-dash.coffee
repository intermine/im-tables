Options = require 'imtables/options'
Dashboard  = require 'imtables/views/dashboard'

# Test helpers.
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'

Options.set 'ModelDisplay.Initially.Closed', true
Options.set 'TableCell.PreviewTrigger', 'hover'
Options.set 'TableCell.IndicateOffHostLinks', false

QUERY =
  name: 'Dashboard Query'
  select: [
    'company.name',
    'name',
    'company.contractors.name',
    'company.contractors.seniority',
    'company.contractors.businessAddress.address',
    'company.contractors.oldComs.name',
    'company.contractors.oldComs.address.address'
  ]
  from: 'Department'
  joins: [
    'Department.company.contractors.businessAddress',
    'Department.company.contractors.oldComs',
  ]

main = -> renderQueries [QUERY], renderQuery
create = (query) -> new Dashboard {query, model: {size: 5}}
renderQuery = renderWithCounter create

global.window.onload = main

