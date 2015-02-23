$ = require 'jquery'

Options = require 'imtables/options'

# Code under test:
Dashboard  = require 'imtables/views/dashboard'
Formatting = require 'imtables/formatting'
Toggles = require '../lib/toggles'

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
  dash = new Dashboard {query, model: {size: 15}}
  dash.bus.on 'list-action:success', (action, list) ->
    console.log "Successful list #{ action }", list
  dash.bus.on 'list-action:failure', (action, err) ->
    console.error "Failed list #{ action }", err
  return dash

QUERY =
  name: 'Dashboard Query'
  select: [
    'company.name',
    'name',
    'employees.name',
    'employees.age'
  ]
  from: 'Department'
  where: [[ 'employees.age', '>', 35 ]]

renderQuery = renderWithCounter create

optionsΤοggles = new Toggles
  model: Options
  toggles: [
    {
      attr: 'icons',
      type: 'enum',
      opts: ['fontawesome', 'glyphicons']
    }
  ]

$ ->
  document.body.appendChild optionsΤοggles.render().el
  renderQueries [QUERY], renderQuery
