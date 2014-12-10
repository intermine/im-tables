_ = require 'underscore'

View = require '../core-view'

# FIXME - check this import
NestedTableModel = require './models/nested-table'
# FIXME - create this file.
ColumnHeader = require './column-header'
# FIXME - check this import
SubTable = require './subtable'
# FIXME - check this import
Cell = require './cell'
# FIXME - create this file, make sure it returns a template
#      - make sure that there is a .btn.undo in it
NoResults = require '../templates/no-results'

# Inner class that only knows how to render results,
# but not where they come from.
module.exports = class ResultsTable extends View

  @nextDirections =
    ASC: "DESC"
    DESC: "ASC"

  className: "im-results-table table table-striped table-bordered"

  tagName: "table"

  attributes:
    width: "100%"
    cellpadding: 0
    border: 0
    cellspacing: 0

  throbber: _.template """
    <tr class="im-table-throbber">
      <td colspan="<%= colcount %>">
        <h2>Requesting Data</h2>
        <div class="progress progress-info progress-striped active">
          <div class="bar" style="width: 100%"></div>
        </div>
      </td>
    </tr>
  """

  initialize: (@query, @blacklistedFormatters, @columnHeaders, @rows) ->
    @minimisedCols = {}
    @query.on 'columnvis:toggle', @onColvisToggle

    @listenTo @columnHeaders, 'reset add remove', @renderHeaders
    @listenTo @columnHeaders, 'reset add remove', @fill
    @listenTo @blacklistedFormatters, 'reset add remove', @fill
    @listenTo @rows, 'reset add remove', @fill

  onColvisToggle: (view) =>
    @minimisedCols[view] = not @minimisedCols[view]
    # Copy the data, so that handlers cannot change our state.
    @query.trigger 'change:minimisedCols', _.extend({}, @minimisedCols), view
    @fill()

  events: ->
    'click .btn.undo': => @query.trigger 'undo'

  render: ->
    @$el.empty()
    @$el.append document.createElement 'thead'
    @renderHeaders()
    @$el.append document.createElement 'tbody'
    @fill()

  fill: ->
    # Clean up old children.
    previousCells = (@currentCells || []).slice()
    for cell in previousCells
      cell.remove()
    @currentCells = []
    return @handleEmptyTable() if @rows.size() < 1

    docfrag = document.createDocumentFragment()

    replacer_of = {}
    @columnHeaders.each (col) ->
      for r in (rs = col.get('replaces'))
        replacer_of[r] = col

    @rows.each (row) => @appendRow docfrag, row, replacer_of

    # Careful - there might be subtables out there - be specific.
    @$el.children('tbody').html docfrag

    # Let listeners know that the table is ready to use.
    @query.trigger "table:filled"

  handleEmptyTable: () ->
    q = @query
    @$("tbody > tr").remove()
    apology = NoResults q
    @$el.append apology

  minimisedColumnPlaceholder: _.template """
    <td class="im-minimised-col" style="width:<%= width %>px">&hellip;</td>
  """

  renderCell: (cell) =>
    base = @query.service.root.replace /\/service\/?$/, ""
    if cell instanceof NestedTableModel
      node = @query.getPathInfo obj.column
      return new SubTable
        model: cell
        cellify: @renderCell
        canUseFormatter: (f) => @canUseFormatter
        mainTable: @
    else
      return new Cell(model: cell)

  canUseFormatter: (formatter) ->
    formatter? and (not @blacklistedFormatters.any (f) -> f.get('formatter') is formatter)

  # tbody :: HTMLElement, row :: RowModel, replacer_of :: {string => Formatter}
  appendRow: (tbody, row, replacer_of) =>
    tr = document.createElement 'tr'
    tbody.appendChild tr
    minWidth = 10
    processed = {}

    # Render models into views
    cellViews = (@renderCell cell for cell in row.get('cells'))

    # cell :: Cell | SubTable, i :: int
    for cell, i in cellViews then do (cell, i) =>
      cellPath = cell.path
      return if processed[cellPath]
      processed[cellPath] = true
      {replaces, formatter, path} = (replacer_of[cellPath]?.toJSON() ? {})
      if replaces?.length > 1
        # Only accept if it is the right type, since formatters expect a type.
        return unless path.equals(cellPath.getParent())
        if formatter?.merge?
          for c in cellViews when _.any(replaces, (x) -> x.equals c.path)
            formatter.merge(cell.model.get('cell'), c.model.get('cell'))

        processed[r] = true for r in replaces

      cell.formatter = formatter if formatter?

      if @minimisedCols[ cellPath ] or (path and @minimisedCols[path])
        $(tr).append @minimisedColumnPlaceholder width: minWidth
      else
        cell.render()
        tr.appendChild cell.el

  # Add headers to the table
  renderHeaders: ->
    docfrag = document.createDocumentFragment()
    tr = document.createElement 'tr'
    docfrag.appendChild tr

    @columnHeaders.each (ch) => @renderHeader ch, tr
            
    # children selector because we only want to go down 1 layer.
    @$el.children('thead').html docfrag

  # Render a single header to the headers
  renderHeader: (model, tr) ->
    header = new ColumnHeader {model, @query, @blacklistedFormatters}
    header.render().$el.appendTo tr
