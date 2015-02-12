$ = require 'jquery'

Options = require 'imtables/options'

# Code under test:
TableModel      = require 'imtables/models/table'
SelectedObjects = require 'imtables/models/selected-objects'
CellModelFactory = require 'imtables/utils/cell-model-factory'
PopoverFactory   = require 'imtables/utils/popover-factory'
Preview     = require 'imtables/views/item-preview'
Formatting = require 'imtables/formatting'

# Test helpers.
BasicTable = require '../lib/basic-table'
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
tableState = new TableModel size: 10

create = (query) ->
  new BasicTable
    model: tableState
    query: query
    popovers: (new PopoverFactory connection, Preview)
    modelFactory: (new CellModelFactory connection, query.model)
    selectedObjects: selectedObjects
    formatters: {Company: formatCompany}

QUERY =
  name: 'subtables'
  select: ['name','employees.name','employees.age']
  from: 'Department'
  joins: ['employees']
  where: [[ 'employees.age', '>', 35 ]]

toggles = [
  {
    attr: 'selecting',
    type: 'bool'
  },
  {
    attr: 'highlitNode',
    type: 'enum',
    opts: ['Department', 'Department.company', 'Department.employees']
  }
]

renderQuery = renderWithCounter create, (->), ['model']

$ ->
  toggles = new Toggles model: tableState, toggles: toggles
  optionsΤοggles = new Toggles
    model: Options
    toggles: [{attr: 'TableCell.PreviewTrigger', type: 'enum', opts: ['hover', 'click']}]

  commonTypeLabel = new Label
    model: selectedObjects
    attr: 'Common Type'
    getter: -> selectedObjects.state.get('commonType') if selectedObjects.length

  toggles.render().$el.appendTo 'body'
  optionsΤοggles.render().$el.appendTo 'body'
  commonTypeLabel.render().$el.appendTo 'body'

  renderQueries [QUERY], renderQuery
