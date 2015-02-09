_ = require 'underscore'
$ = jQuery = require 'jquery' # Used for overlays

CoreView = require '../core-view'
Options = require '../options'
Templates = require '../templates'
Collection = require '../core/collection'
CoreModel = require '../core-model'

renderError = require './table/render-error'
TableModel = require '../models/table'
ColumnHeaders = require '../models/column-headers'
UniqItems = require '../models/uniq-items'
RowsCollection = require '../models/rows'
CellModelFactory = require '../utils/cell-model-factory'
TableResults = require '../utils/table-results'

Pagination = require './table/pagination'
ResultsTable = require './table/inner'
PageSizer = require './table/page-sizer'
TableSummary = require './table/summary'

module.exports = class Table extends CoreView

  # The data model for the table.
  Model: TableModel

  className: "im-table-container"

  parameters: [
    'query',          # the query this table contains results for.
    'selectedObjects' # currently selected entities, shared with components that need selections
  ]

  optionalParameters: ['columnHeaders', 'blacklistedFormatters']

  initState: ->
    # terrible name for this property - it means the factor by
    # which we multiply the page size when requesting rows - so a table
    # with ten rows will request 100 rows, so that paging is quicker.
    @state.set pipeFactor: 10

  # @param query The query this view is bound to.
  # @param selector Where to put this table.
  initialize: ->
    super
    @cellModelFactory = new CellModelFactory @query, @selectedObjects

    # columnHeaders contains the header information.
    @columnHeaders ?= new ColumnHeaders
    # Formatters we are not allowed to use.
    @blacklistedFormatters ?= new UniqItems
    # rows contains the current rows in the table
    @rows = new RowsCollection

    @setFreshness()

    @listenTo @blacklistedFormatters, 'reset add remove', @buildColumnHeaders

    @listenTo @columnHeaders, 'change:minimised', @onChangeHeaderMinimised

    @listenToQuery()
    # Always good to know the API version, but we
    # aren't currently using it for anything, but it
    # is a chance to fail very early if we cannot access
    # the web-service.
    @query.service.fetchVersion (error, version) => @model.set {error, version}
    @query.count (error, count) => @model.set {error, count}

    @fillRows().then (-> console.debug 'initial data loaded'), (error) => @model.set {error}
    console.debug 'initialised table'

  modelEvents: ->
    'change:phase': @reRender
    'change:freshness change:start change:size': @fillRows
    'change:count': @onChangeCount
    'change:error': @onChangeError

  # Ideally we should use fewer events, and more models.
  queryEvents: ->
    'change:sortorder change:views change:constraints change:joins': @setFreshness
    'start:list-creation': @setSelecting
    'stop:list-creation': @unsetSelecting
    'table:filled': @onDraw

  unsetCache: -> @model.unset 'cache'
  onChangeCache: -> @model.set(lowerBound: null, upperBound: null) unless @model.get('cache')?
  onChangeCount: -> @query.trigger 'count:is', @model.get 'count' # daft - TODO: remove
  onChangeError: -> @model.set(phase: 'ERROR') if @model.get('error')

  listenToQuery: -> for evt, hander of @queryEvents()
    @listenTo @query, evt, handler

  # TODO - move this to a model shared between the list dialogue button and the cells.
  # that model is the table model - make sure the list dialogue gets a ref.
  onDraw: -> # Preserve list creation state across pages.
    @query.trigger("start:list-creation") if @model.get 'selecting'

  remove: -> # remove self, and all children, and remove listeners
    @cellModelFactory.destroy()
    delete @cellModelFactory
    super

  # Write the change in minimised state to the table model
  onChangeHeaderMinimised: (m) ->
    path = @query.makePath m.get('path')
    minimisedCols = @model.get('minimisedColumns')

    if m.get('minimised')
      minimisedCols.add path
    else
      minimisedCols.remove path

  setSelecting: => @model.set selecting: true

  unsetSelecting: => @model.set selecting: false

  canUseFormatter: (formatter) =>
    formatter? and (not @blacklistedFormatters.contains formatter)

  # Anything that can bust the cache should go in here.
  # As of this point, that just means the state of the query,
  # which can be represented as an (xml) string.
  setFreshness: -> @model.set freshness: @query.toXML()

  # Set the column headers correctly for the current state of the query,
  # setting the minimised state to respect the state of model.minimisedColumns
  buildColumnHeaders: ->
    silently = {silent: true}
    minimisedCols = @model.get('minimisedColumns')
    isMinimised = (ch) => minimisedCols.contains(@query.makePath ch.get('path'))

    @columnHeaders.setHeaders @query, @blacklistedFormatters
    @columnHeaders.forEach (ch) => ch.set {minimised: (isMinimised ch)}, silently

  ## Filling the rows is a two step process - first we check the row cache to see
  ## if we already have these rows, or update it if not. Only then do we go about
  ## updating the rows collection.
  ## 
  ## Function for buffering data for a request. Each request fetches a page of
  ## pipe_factor * size, and if subsequent requests request data within this range, then
  ##
  ## @param src URL passed from DataTables. Ignored.
  ## @param param list of {name: x, value: y} objects passed from DataTables
  ## @param callback fn of signature: resultSet -> ().
  ##
  ##
  fillRows: ->
    console.debug 'filling rows'
    success = => @model.set phase: 'SUCCESS'
    error = (e) => @model.set phase: 'ERROR', error: (e ? new Error('unknown error'))
    @fetchRows().then(@fillRowsCollection).then success, error

  fetchRows: ->
    {start, size} = @model.pick 'start', 'size'
    cache = TableResults.getCache @query
    cache.fetchRows start, size

  overlayTable: =>
    return unless @table and @drawn
    elOffset = @$el.offset()
    tableOffset = @table.$el.offset()
    jQuery('.im-table-overlay').remove()
    @overlay = jQuery @make "div",
      class: "im-table-overlay discrete " + Options.get('StylePrefix')
    @overlay.css
        top: elOffset.top
        left: elOffset.left
        width: @table.$el.outerWidth(true)
        height: (tableOffset.top - elOffset.top) + @table.$el.outerHeight()
    @overlay.append @make "h1", {}, "Requesting data..."
    @overlay.find("h1").css
        top: (@table.$el.height() / 2) + "px"
        left: (@table.$el.width() / 4) + "px"
    @overlay.appendTo 'body'
    _.delay (=> @overlay.removeClass "discrete"), 100

  removeOverlay: => @overlay?.remove()

  ##
  ## Populate the rows collection with the current rows from cache.
  ## This requires that the cache has been populated, so should only
  ## be called from `::fillRows`
  ##
  ## @param echo The results table request control.
  ## @param start The index of the first result desired.
  ## @param size The page size
  ##
  fillRowsCollection: (rows) =>
    factory = @cellModelFactory
    offset = @model.get 'start'
    models = rows.map (row, i) ->
      index: (offset + i)
      cells: (factory.createModel c for c in row)

    @rows.set models

  makeTable: -> @make 'table',
    class: "table table-striped table-bordered"
    width: "100%"

  renderFetching: ->
    """
      <h2>Building table</h2>
      <div class="progress progress-striped active progress-info">
          <div class="bar" style="width: 100%"></div>
      </div>
    """

  renderError: -> renderError @query, @model.get('error')

  renderTable: ->
    frag = document.createDocumentFragment()
    $widgets = $('<div>').appendTo frag
    for component in Options.get('TableWidgets', []) when "place#{ component }" of @
      method = "place#{ component }"
      @[ method ]( $widgets )
    $widgets.append Templates.clear

    tel = @makeTable()
    frag.appendChild tel

    table = new ResultsTable {@query, tableState: @model, @blacklistedFormatters, @columnHeaders, @rows}

    @renderChildAt 'inner', table, tel

    return frag

  template: ->
    switch @state.get 'phase'
      when 'FETCHING' then @renderFetching()
      when 'ERROR' then @renderError()
      when 'SUCCESS' then @renderTable()
      else throw new Error "Unknown state: #{ @state.get 'phase' }"

  renderWidget: (name, container, Child) ->
    @renderChild name, (new Child {@model}), container

  placePagination: ($widgets) ->
    @renderWidget 'pagination', $widgets, Pagination

  placePageSizer: ($widgets) ->
    @renderWidget 'pagesizer', $widgets, PageSizer

  placeTableSummary: ($widgets) ->
    @renderWidget 'tablesummary', $widgets, TableSummary

  # FIXME - check references
  getCurrentPageSize: -> @model.get 'size'

  # FIXME - check references
  getCurrentPage: () ->
    {start, size} = @model.toJSON()
    if size then Math.floor(start / size) else 0

