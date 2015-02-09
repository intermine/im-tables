_ = require 'underscore'

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
    'history',        # History of states.
    'selectedObjects' # currently selected entities, shared with components that need selections
  ]

  optionalParameters: ['columnHeaders', 'blacklistedFormatters']

  # @param query The query this view is bound to.
  # @param selector Where to put this table.
  initialize: ->
    super
    @onChangeQuery()
    @listenTo @history, 'changed:current', @onChangeQuery

    # A cell model factory for creating cell models.
    @cellModelFactory ?= new CellModelFactory @query.service, @query.model
    # columnHeaders contains the header information.
    @columnHeaders ?= new ColumnHeaders
    # Formatters we are not allowed to use.
    @blacklistedFormatters ?= new UniqItems
    # rows contains the current rows in the table
    @rows = new RowsCollection

    @listenTo @blacklistedFormatters, 'reset add remove', @buildColumnHeaders

    @listenTo @columnHeaders, 'change:minimised', @onChangeHeaderMinimised

    console.debug 'initialised table'


  onChangeQuery: ->
    # save a reference, just to make life easier.
    @query = @history.getCurrentQuery()

    # We wait for the version not because it is needed but because it allows
    # us to diagnose connectivity problems before running a big query.
    @fetchVersion().then =>
      @query.count (error, count) => @model.set {error, count}
      # Triggers page fill; see model events.
      @setFreshness()

  fetchVersion: ->
    # Always good to know the API version. We
    # aren't currently using it for anything, but it
    # is a chance to fail very early and cheaply
    # if we cannot access the web-service.
    @query.service
          .fetchVersion()
          .then (version) => @model.set {version}
          .then null, (e) => onConnectionError e

  onConnectionError: (e) ->
    console.error e # Log this for diagnostics.
    err = new Error 'Could not connect to server'
    err.key = 'setup.ConnectionError'
    @model.set error: err

  modelEvents: ->
    'change:phase': @reRender
    'change:freshness change:start change:size': @fillRows
    'change:count': @onChangeCount
    'change:error': @onChangeError

  onChangeCount: -> @query.trigger 'count:is', @model.get 'count' # daft - TODO: remove
  onChangeError: -> @model.set(phase: 'ERROR') if @model.get('error')

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

  # Request some rows, using a cache as an intermediary, and then fill
  # our rows collection with the result.
  fillRows: ->
    console.debug 'filling rows'
    {start, size} = @model.pick 'start', 'size'
    success = => @model.set phase: 'SUCCESS'
    error   = (e) => @model.set phase: 'ERROR', error: (e ? new Error('unknown error'))

    TableResults.getCache @query
                .fetchRows start, size
                .then (rows) => @fillRowsCollection
                .then success, error

  # Take the rows returned from somewhere (the cache, usually),
  # and then turn the data into cell models and stuff them in turn
  # into rows.
  fillRowsCollection: (rows) ->
    createModel = @cellModelFactory.getCreator @query
    offset = @model.get 'start'
    models = rows.map (row, i) ->
      index: (offset + i)
      cells: (createModel c for c in row)

    @rows.set models

  overlayTable: =>
    # TODO - de-jquery this method.
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

  # Rendering logic
 
  template: -> switch @state.get 'phase'
    when 'FETCHING' then @renderFetching()
    when 'ERROR' then @renderError()
    when 'SUCCESS' then @renderTable()
    else throw new Error "Unknown state: #{ @state.get 'phase' }"

  renderFetching: -> """
    <h2>Building table</h2>
    <div class="progress progress-striped active progress-info">
        <div class="bar" style="width: 100%"></div>
    </div>
  """

  renderError: -> renderError @query, @model.get('error')

  renderTable: ->
    frag = document.createDocumentFragment()
    widgets = document.createElement 'div'
    clear = document.createElement 'div'

    frag.appendChild widgets
    for component in Options.get('TableWidgets', []) when "place#{ component }" of @
      method = "place#{ component }"
      @[ method ]( widgets )
    clear.style.clear = 'both'
    widgets.appendChild clear

    table = new ResultsTable {@query, tableState: @model, @blacklistedFormatters, @columnHeaders, @rows}

    @renderChild 'inner', table, frag

    return frag

  renderWidget: (name, container, Child) ->
    @renderChild name, (new Child {@model}), container

  placePagination: (widgets) ->
    @renderWidget 'pagination', widgets, Pagination

  placePageSizer: (widgets) ->
    @renderWidget 'pagesizer', widgets, PageSizer

  placeTableSummary: (widgets) ->
    @renderWidget 'tablesummary', widgets, TableSummary

