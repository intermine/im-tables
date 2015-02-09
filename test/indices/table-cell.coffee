$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'

CoreModel = require 'imtables/core-model'
CoreView = require 'imtables/core-view'
Options = require 'imtables/options'

# Code under test:
TableModel      = require 'imtables/models/table'
SelectedObjects = require 'imtables/models/selected-objects'
RowsCollection  = require 'imtables/models/rows'
CellModelFactory = require 'imtables/utils/cell-model-factory'
PopoverFactory   = require 'imtables/utils/popover-factory'
TableResults     = require 'imtables/utils/table-results'
Preview     = require 'imtables/views/item-preview'
Cell        = require 'imtables/views/table/cell'

Toggles = require '../lib/toggles'
renderQueries = require '../lib/render-queries.coffee'
renderWithCounter = require '../lib/render-query-with-counter-and-displays'
{connection} = require '../lib/connect-to-service'

Options.set 'ModelDisplay.Initially.Closed', true
# Make these toggleable...
Options.set 'TableCell.PreviewTrigger', 'hover'
Options.set 'TableCell.IndicateOffHostLinks', false

canUseFormatter = -> false
popoverFactory = new PopoverFactory connection, Preview
selectedObjects = new SelectedObjects connection
tableState = new TableModel

class BasicTable extends CoreView

  Model: TableModel

  tagName: 'table'

  className: 'table table-striped'

  initialize: ({@query}) ->
    super
    @cellModelFactory = new CellModelFactory @query, @selectedObjects
    @rows = new RowsCollection
    @listenTo @rows, 'add remove reset', @reRender
    # This table doesn't do paging, reloading or anything fancy at all, therefore
    # it does just this one single simple fetch.
    TableResults.getCache @query
                .fetchRows 0, 10
                .then (rows) => @setRows rows
                .then -> console.log 'set rows'
                .then null, (e) -> console.error 'error setting rows', e

  template: _.template """
    <thead>
      <tr>
        <% _.each(headers, function (header) { %>
          <th><%- header %></th>
        <% }); %>
      </tr>
    </thead>
    <tbody></tbody>
  """

  getData: -> _.extend @getBaseData(), headers: @query.views

  postRender: ->
    @$body = @$ 'tbody'
    @rows.forEach (row) => @addRow row

  setRows: (rows) -> # the same logic as Table::fillRowsCollection, minus start.
    console.log 'GOT', rows
    factory = @cellModelFactory
    models = rows.map (row, i) ->
      index: i
      cells: (factory.createModel c for c in row)

    @rows.set models

  addRow: (row) ->
    @renderChild row.id, (new RowView model: row), @$body

class RowView extends CoreView

  tagName: 'tr'

  postRender: ->
    service = connection
    popovers = popoverFactory
    @model.get('cells').forEach (model, i) =>
      @renderChild i, (new Cell {model, service, popovers, selectedObjects, tableState})

create = (query) -> new BasicTable {query, model: tableState}

QUERY =
  name: 'cell query'
  select: [
    'company.name',
    'name',
    'employees.name',
    'employees.age'
  ]
  from: 'Department'
  where: [[ 'employees.age', '>', 35 ]]

renderQuery = renderWithCounter create, (->), ['model', 'rows']

$ ->
  toggles = new Toggles model: tableState, toggles: ['selecting']
  toggles.render().$el.appendTo 'body'
  renderQueries [QUERY], renderQuery
