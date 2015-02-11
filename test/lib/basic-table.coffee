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
    {start, size} = @model.pick 'start', 'size'
    @views = new ColumnHeaders()
    @views.setHeaders(@query, (new Collection))
    @rows = new RowsCollection
    @makeCell = CellFactory @query.service,
      query: @query
      expandedSubtables: (new Collection)
      popoverFactory: @popovers
      selectedObjects: @selectedObjects
      tableState: @model
      canUseFormatter: (=> !!@model.get('formatting'))
      getFormatter: ((p) => @formatters[p.getType().name]) # the real fn is more complex.

    # This table doesn't do paging, reloading or anything fancy at all, therefore
    # it does just this one single simple fetch.
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

    @rows.set models

class TableHeader extends CoreView
  
  tagName: 'thead'

  parameters: ['minimisedColumns']

  collectionEvents: ->
    'add change:displayName': @reRender

  getData: -> _.extend super, cssClass: pathToCssClass

  events: -> _.object @collection.map (pm) ->
    ename = "click th.#{ pathToCssClass pm.get('path') }"
    handler = -> @minimisedColumns.toggle pm.pathInfo()
    [ename, handler]

  template: _.template """
    <tr>
      <% _.each(collection, function (header) { %>
        <th class="<%- cssClass(header.path) %>">
          <%- header.displayName || header.path %>
        </th>
      <% }); %>
    </tr>
  """

class TableBody extends CoreView

  tagName: 'tbody'

  parameters: ['makeCell']

  collectionEvents: -> add: (row) -> @addRow row

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
