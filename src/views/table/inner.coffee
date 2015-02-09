_ = require 'underscore'

View = require '../../core-view'

types = require '../../core/type-assertions'

PathSet = require '../../models/path-set'
NestedTableModel = require '../../models/nested-table'
ColumnHeader = require './header'
ColumnHeaders = require '../../models/column-headers'
PopoverFactory = require '../../utils/popover-factory'
History = require '../../models/history'
cellFactory = require './cell-factory'

# FIXME - create this file, make sure it returns a template
#      - make sure that there is a .btn.undo in it
NoResults = require '../templates/no-results'

Preview = require '../item-preview'

# Inner class that only knows how to render results,
# but not where they come from.
module.exports = class ResultsTable extends View

  className: "im-results-table table table-striped table-bordered"

  tagName: 'table'

  throbber: Templates.template 'table-throbber'

  parameters: [
    'history',
    'blacklistedFormatters',
    'columnHeaders',
    'rows',
    'tableState',
    'selectedObjects'
  ]

  parameterTypes:
    history: (types.InstanceOf History, 'History')
    blacklistedFormatters: types.Collection
    rows: types.Collection
    tableState: (types.InstanceOf TableModel, 'TableModel')
    columnHeaders: (types.InstanceOf ColumnHeaders, 'ColumnHeaders')
    selectedObjects: (types.InstanceOf SelectedObjects, 'SelectedObjects')

  initialize: ->
    super
    @query = @history.getCurrentQuery()
    @expandedSubtables = new PathSet
    @popoverFactory = new PopoverFactory @query.service, Preview
    @cellFactory = cellFactory @query.service, @

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
    'click .btn.undo': @undo
    
  undo: -> @history.popState()

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

    column_for = {}
    @columnHeaders.each (col) ->
      for r in (rs = col.get('replaces'))
        column_for[r] = col

    @rows.each (row) => @appendRow docfrag, row, column_for

    # Careful - there might be subtables out there - be specific.
    @$el.children('tbody').html docfrag

    # Let listeners know that the table is ready to use.
    @query.trigger "table:filled"

  handleEmptyTable: () ->
    q = @query
    @$("tbody > tr").remove()
    apology = NoResults q
    @$el.append apology

  minimisedColumnPlaceholder: (width) ->
    td = document.createElement 'td'
    td.className = 'im-minimised-col'
    td.style.width = "#{ width }px"
    td.innerHTML = '&hellip;'
    return td

  renderCell: (cell) -> @cellFactory.create cell

  # can be used if it exists and hasn't been black-listed.
  canUseFormatter: (formatter) =>
    formatter? and (not @blacklistedFormatters.findWhere {formatter})

  # tbody :: HTMLElement, row :: RowModel, column_for :: {string => Column}
  appendRow: (tbody, row, column_for) =>
    tr = document.createElement 'tr'
    tbody.appendChild tr
    minWidth = 10  # TODO: does this really need to be here?
    processed = {} # keep a track of which paths we have processed.

    # :: [CellView] (common api is ::getPath())
    cellViews = (@renderCell cell for cell in row.get('cells'))

    for cell, i in cellViews then do (cell, i) =>
      # What we are doing here is looking for paths to skip because they are
      # replaced due to formatting.
      cellPath = cell.getPath()
      return if processed[cellPath]

      processed[cellPath] = true
      column = column_for[cellPath]

      {replaces, formatter, path} = (column?.toJSON() ? {})
      if replaces?.length > 1
        # Only accept if it is the right type, since formatters expect a type.
        return unless path.equals(cellPath.getParent())
        if formatter?.merge?
          for c in cellViews when _.any(replaces, (x) -> x.equals c.path)
            formatter.merge(cell.model.get('cell'), c.model.get('cell'))

        processed[r] = true for r in replaces

      cell.formatter = formatter if formatter?

      if @minimisedCols[ cellPath ] or (path and @minimisedCols[path])
        tr.appendChild @minimisedColumnPlaceholder minWidth
      else
        cell.render()
        tr.appendChild cell.el

  # Add headers to the table
  renderHeaders: ->
    docfrag = document.createDocumentFragment()
    tr = document.createElement 'tr'
    docfrag.appendChild tr
    headerOpts = {@query, @expandedSubtables, @blacklistedFormatters}

    @columnHeaders.each @renderHeader tr, headerOpts
            
    # children selector because we only want to go down 1 layer.
    @$el.children('thead').html docfrag

  # Render a single header to the row of headers
  renderHeader: (tr, opts) -> (model, i) =>
    header = new ColumnHeader _.extend {model}, opts
    @renderChild "header_#{ i }", header, tr

  remove: ->
    @popoverFactory.destroy()
    delete @popoverFactory
    delete @cellFactory
    super
