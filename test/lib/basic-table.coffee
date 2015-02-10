_ = require 'underscore'

CoreView       = require 'imtables/core-view'
TableModel     = require 'imtables/models/table'
RowsCollection = require 'imtables/models/rows'
TableResults   = require 'imtables/utils/table-results'
Cell           = require 'imtables/views/table/cell'

pathToCssClass = (path) -> String(path).replace /\./g, '-'

module.exports = class BasicTable extends CoreView

  Model: TableModel

  tagName: 'table'

  className: 'table table-striped table-bordered table-condensed'

  parameters: [
    'query',
    'popovers',
    'modelFactory',
    'selectedObjects',
  ]

  formatters: {}

  optionalParameters: ['formatters']

  initialize: ->
    super
    {start, size} = @model.pick 'start', 'size'
    @rows = new RowsCollection
    @listenTo @rows, 'add', (row) -> @addRow row
    # This table doesn't do paging, reloading or anything fancy at all, therefore
    # it does just this one single simple fetch.
    TableResults.getCache @query
                .fetchRows start, size
                .then (rows) => @setRows rows
                .then null, (e) -> console.error 'error setting rows', e

  template: _.template """
    <thead>
      <tr>
        <% _.each(headers, function (header) { %>
          <th class="<%- cssClass(header) %>"><%- header %></th>
        <% }); %>
      </tr>
    </thead>
    <tbody></tbody>
  """

  events: ->
    e = {}
    @query.views.forEach (v) =>
      path = @query.makePath v
      e["click th.#{ pathToCssClass v }"] = -> @model.get('minimisedColumns').toggle path
    return e

  getData: -> _.extend @getBaseData(), cssClass: pathToCssClass, headers: @query.views

  postRender: ->
    frag = document.createDocumentFragment 'tbody'
    @$body = @$ 'tbody'
    @rows.forEach (row) => @addRow row, frag
    @$body.html frag

  setRows: (rows) -> # the same logic as Table::fillRowsCollection, minus start.
    createModel = @modelFactory.getCreator @query
    models = rows.map (row, i) ->
      index: i
      cells: (createModel c for c in row)

    @rows.set models

  addRow: (row, tbody) ->
    tbody ?= @$ 'tbody'
    @renderChild row.id, (new RowView model: row, table: @), tbody

class RowView extends CoreView

  tagName: 'tr'

  parameters: ['table']

  postRender: ->
    {popovers, formatters, selectedObjects} = @table
    service = @table.query.service
    tableState = @table.model

    @model.get('cells').forEach (model, i) =>
      opts = {model, service, popovers, selectedObjects, tableState}
      type = model.get('entity').get('class')
      if formatter = formatters[type]
        opts.formatter = formatter

      @renderChild i, (new Cell opts)

  remove: ->
    delete @table
    super
