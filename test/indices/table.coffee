
$ = require 'jquery'

Options = require 'imtables/options'

# Code under test:
Table           = require 'imtables/views/table'
TableModel      = require 'imtables/models/table'
History         = require 'imtables/models/history'
SelectedObjects = require 'imtables/models/selected-objects'
Formatting      = require 'imtables/formatting'

# Test helpers.
Toggles = require '../lib/toggles'
Label = require '../lib/label'
formatCompany = require '../lib/formatters/testmodel/company'
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'
{connection} = require '../lib/connect-to-service'

Options.set 'ModelDisplay.Initially.Closed', true
# Make these toggleable...
Options.set 'TableCell.PreviewTrigger', 'hover'
Options.set 'TableCell.IndicateOffHostLinks', false
Options.set 'TableResults.CacheFactor', 2

selectedObjects = new SelectedObjects connection
tableState = new TableModel size: 10, formatting: true
history = new History

create = (query) ->
  history.setInitialState query

  new Table {model: tableState, history, selectedObjects}

QUERY =
  name: 'Result Table Query'
  select: [
    'company.name',
    'name',
    'employees.name',
    'employees.age'
  ]
  from: 'Department'
  where: [[ 'employees.age', '>', 35 ]]

toggles = [
  {attr: 'selecting', type: 'bool'},
  {attr: 'highlitNode', type: 'enum', opts: ['Department', 'Department.company', 'Department.employees']}
]

renderQuery = renderWithCounter create, (->), ['model', 'rows']

$ ->

  toggles = new Toggles model: tableState, toggles: toggles
  optionsΤοggles = new Toggles
    model: Options
    toggles: [{attr: 'TableCell.PreviewTrigger', type: 'enum', opts: ['hover', 'click']}]

  commonTypeLabel = new Label
    model: selectedObjects
    attr: 'Common Type'
    getter: -> selectedObjects.state.get('commonType') if selectedObjects.length

  body = document.body
  body.appendChild toggles.render().el
  body.appendChild optionsΤοggles.render().el
  body.appendChild commonTypeLabel.render().el

  renderQueries [QUERY], renderQuery
