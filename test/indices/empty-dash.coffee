# There should be a helpful notice in the table, and the export button should
# be disabled.
$ = require 'jquery'

Options = require 'imtables/options'

# Code under test:
Dashboard  = require 'imtables/views/dashboard'
Formatting = require 'imtables/formatting'

# Test helpers.
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'
{authenticatedConnection} = require '../lib/connect-to-service'

Options.set 'ModelDisplay.Initially.Closed', true
# Make these toggleable...
Options.set 'TableCell.PreviewTrigger', 'hover'
Options.set 'TableCell.IndicateOffHostLinks', false

create = (query) ->
  query.service = authenticatedConnection # not pretty, but easy.
  new Dashboard {query, model: {size: 15}}

QUERY =
  name: 'IT Department'
  select: [
    'company.name',
    'name',
    'employees.name',
    'employees.age'
  ]
  from: 'Department'
  where: [[ 'name', '=', 'IT' ]]

renderQuery = renderWithCounter create

$ -> renderQueries [QUERY], renderQuery
