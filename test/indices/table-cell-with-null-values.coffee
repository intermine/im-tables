$ = require 'jquery'

Options = require 'imtables/options'

# Code under test:
TableModel      = require 'imtables/models/table'
SelectedObjects = require 'imtables/models/selected-objects'
CellModelFactory = require 'imtables/utils/cell-model-factory'
PopoverFactory   = require 'imtables/utils/popover-factory'
Preview     = require 'imtables/views/item-preview'

# Test helpers.
BasicTable = require '../lib/basic-table'
Toggles = require '../lib/toggles'
Label = require '../lib/label'
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'
{connection} = require '../lib/connect-to-service'

Options.set 'ModelDisplay.Initially.Closed', true
# Make these toggleable...
Options.set 'TableCell.PreviewTrigger', 'hover'
Options.set 'TableCell.IndicateOffHostLinks', false
Options.set 'TableResults.CacheFactor', 2

QUERY =
  name: 'cell query'
  select: [
    'name',
    'employees.name',
    'employees.end',
    'employees.address.address'
  ]
  where: [
    ['employees.name', '>', 'dan'],
    ['employees.name', '<', 'erika']
  ]
  from: 'Department'
  joins: ['employees.address']
  orderBy: ['employees.name']

TOGGLES = [
  {attr: 'selecting', type: 'bool'},
  {
    attr: 'highlitNode',
    type: 'enum',
    opts: ['Department', 'Department.employees', 'Department.employees.address']}
]

selectedObjects = new SelectedObjects connection
tableState = new TableModel size: 25

create = (query) ->
  new BasicTable
    model: tableState
    query: query
    popovers: (new PopoverFactory connection, Preview)
    modelFactory: (new CellModelFactory connection, query.model)
    selectedObjects: selectedObjects

renderQuery = renderWithCounter create, (->), ['model', 'rows']

main = ->
  toggles = new Toggles model: tableState, toggles: TOGGLES
  commonTypeLabel = new Label
    model: selectedObjects
    attr: 'Common Type'
    getter: -> selectedObjects.state.get('commonType') if selectedObjects.length

  toggles.render().$el.appendTo 'body'
  commonTypeLabel.render().$el.appendTo 'body'

  renderQueries [QUERY], renderQuery

$ main
