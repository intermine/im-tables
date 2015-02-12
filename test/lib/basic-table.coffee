_ = require 'underscore'

CoreView       = require 'imtables/core-view'
Collection     = require 'imtables/core/collection'
TableModel     = require 'imtables/models/table'
RowsCollection = require 'imtables/models/rows'
PathModel      = require 'imtables/models/path'
ColumnHeaders  = require 'imtables/models/column-headers'
TableResults   = require 'imtables/utils/table-results'
CellFactory    = require 'imtables/views/table/cell-factory'

pathToCssClass = (path) -> String(path).replace /\./g, '-'

class ViewList extends Collection

  model: PathModel

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
    @views = new ColumnHeaders()
    @rows = new RowsCollection
    getFormatter = (n, c) => # A very simple formatter assignment
      type = n.getType().name
      @formatters[type] ? @formatters["#{ type }.#{ c.end.name }"]

    @makeCell = CellFactory @query.service,
      query: @query
      expandedSubtables: (new Collection)
      popoverFactory: @popovers
      selectedObjects: @selectedObjects
      tableState: @model
      canUseFormatter: (=> !!@model.get('formatting'))
      getFormatter: getFormatter

    @loadData()
    @listenTo @query, 'change:constraints change:views', @loadData

  loadData: ->
    @views.setHeaders(@query, (new Collection))
    {start, size} = @model.pick 'start', 'size'
    TableResults.getCache @query
                .fetchRows start, size
                .then @setRows
                .then null, (e) -> console.error 'error setting rows', e

  postRender: -> @renderHead(); @renderBody()

  renderHead: -> @renderChild 'thead', new TableHeader
    collection: @views
    minimisedColumns: @model.get('minimisedColumns')

  renderBody: -> @renderChild 'tbody', new TableBody
    collection: @rows
    makeCell: @makeCell

  setRows: (rows) => # the same logic as Table::fillRowsCollection, minus start.
    createModel = @modelFactory.getCreator @query
    models = rows.map (row, i) ->
      index: i
      cells: (createModel c for c in row)

    @rows.reset models

class TableHeader extends CoreView
  
  tagName: 'thead'

  parameters: ['minimisedColumns']

  collectionEvents: ->
    'add remove': -> @delegateEvents()
    'add remove change:displayName': @reRender

  initialize: ->
    super
    @listenTo @minimisedColumns, 'add remove', @reRender

  getData: -> _.extend super, cssClass: pathToCssClass, minimised: @getMinimisedState()

  getMinimisedState: ->
    _.object @minimisedColumns.map (p) -> [p.get('item').toString(), true]

  events: -> _.object @collection.map (pm) ->
    ename = "click th.#{ pathToCssClass pm.get('path') }"
    handler = -> @minimisedColumns.toggle pm.pathInfo()
    [ename, handler]

  template: _.template """
    <tr>
      <% _.each(collection, function (header) { %>
        <th class="<%- cssClass(header.path) %>">
          <% if (minimised[header.path]) { %>
            &hellip;
          <% } else { %>
            <%- header.displayName || header.path %>
          <% } %>
        </th>
      <% }); %>
    </tr>
  """

class TableBody extends CoreView

  tagName: 'tbody'

  parameters: ['makeCell']

  collectionEvents: ->
    reset: @reRender
    add: (row) -> @addRow row
    remove: (row) ->
      console.log 'removing', row.id
      @removeChild row.id

  template: ->

  renderChildren: ->
    frag = document.createDocumentFragment 'tbody'
    @collection.forEach (row) => @addRow row, frag
    @el.appendChild frag

  addRow: (row, tbody) ->
    tbody ?= @el
    @renderChild row.id, (new RowView model: row, makeCell: @makeCell), tbody

class RowView extends CoreView
  tagName: 'tr'
  parameters: ['makeCell']
  postRender: -> @model.get('cells').forEach (model, i) =>
    @renderChild i, (@makeCell model)
