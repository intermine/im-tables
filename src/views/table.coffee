_ = require 'underscore'

CoreView = require '../core-view'
Options = require '../options'
Templates = require '../templates'
Messages = require '../messages'
Collection = require '../core/collection'
CoreModel = require '../core-model'
Types = require '../core/type-assertions'

# Data models.
TableModel      = require '../models/table'
ColumnHeaders   = require '../models/column-headers'
UniqItems       = require '../models/uniq-items'
RowsCollection  = require '../models/rows'
SelectedObjects = require '../models/selected-objects'
History         = require '../models/history'

CellModelFactory = require '../utils/cell-model-factory'
TableResults = require '../utils/table-results'

# The sub-views that render the table state.
ResultsTable = require './table/inner'
ErrorNotice = require './table/error-notice'
Pagination = require './table/pagination'
PageSizer = require './table/page-sizer'
TableSummary = require './table/summary'

require '../messages/table'

UNKNOWN_ERROR =
  message: 'Unknown error'
  key: 'error.Unknown'

module.exports = class Table extends CoreView

  # Convenience for creating tables from the outside.
  @create: (query, model) ->
    Types.assertMatch Types.Query, query
    model ?= new TableModel
    history = new History
    selectedObjects = new SelectedObjects
    history.setInitialState query
    new Table {history, model, selectedObjects}

  # The data model for the table.
  Model: TableModel

  className: "im-table-container"

  parameters: [
    'history',        # History of states, tells us the current query.
    'selectedObjects' # currently selected entities
  ]

  parameterTypes:
    history: (Types.InstanceOf History, 'History')
    selectedObjects: (Types.InstanceOf SelectedObjects, 'SelectedObjects')

  optionalParameters: ['columnHeaders', 'blacklistedFormatters']

  cellModelFactory: null # initialised in Table::onChangeQuery

  # @param query The query this view is bound to.
  # @param selector Where to put this table.
  initialize: ->
    super
    # columnHeaders contains the header information.
    @columnHeaders ?= new ColumnHeaders
    # Formatters we are not allowed to use.
    @blacklistedFormatters ?= new UniqItems
    # rows contains the current rows in the table
    @rows = new RowsCollection

    @listenTo @history, 'changed:current', @onChangeQuery
    @listenTo @blacklistedFormatters, 'reset add remove', @buildColumnHeaders
    @listenTo @columnHeaders, 'change:minimised', @onChangeHeaderMinimised

    @onChangeQuery()
    console.debug 'initialised table'

  onChangeQuery: ->
    # save a reference, just to make life easier.
    {service, model} = @query = @history.getCurrentQuery()

    # A cell model factory for creating cell models
    # does not need rebuilding.
    @cellModelFactory ?= new CellModelFactory service, model
    @buildColumnHeaders()

    # We wait for the version not because it is needed but because it allows
    # us to diagnose connectivity problems before running a big query.
    @fetchVersion().then =>
      @query.count (error, count) => @model.set {error, count}
      @setFreshness() # Triggers page fill; see model events.

  # Always good to know the API version. We
  # aren't currently using it for anything, but it
  # is a chance to fail very early and cheaply
  # if we cannot access the web-service.
  fetchVersion: ->
    @query.service
          .fetchVersion()
          .then (version) => @model.set {version}
          .then null, (e) => onConnectionError e

  onConnectionError: (e) ->
    err = new Error 'Could not connect to server'
    err.key = 'error.ConnectionError'
    @model.set error: err

  # We fetch data if the query or the page changes.
  # When we fetch data because the page changed we just overlay the
  # table. When the query itself changed we reset back to fetching
  # and run back through the table life-cycle phases.
  modelEvents: ->
    'change:freshness change:start change:size': @fillRows
    'change:start change:size': @overlayTable
    'change:fill': @removeOverlay
    'change:freshness': @resetPhase
    'change:phase': @onChangePhase
    'change:error': @onChangeError

  onChangePhase: ->
    @removeOverlay()
    @reRender()

  resetPhase: -> @model.set phase: 'FETCHING'

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
    isMin = (ch) => minimisedCols.contains(@query.makePath ch.get('path'))

    @columnHeaders.setHeaders @query, @blacklistedFormatters
    @columnHeaders.forEach (ch) => ch.set {minimised: (isMin ch)}, silently

  # Request some rows, using a cache as an intermediary, and then fill
  # our rows collection with the result, and then record how successful
  # we were, finally bumping the fill count.
  fillRows: ->
    console.debug 'filling rows'
    {start, size} = @model.pick 'start', 'size'
    success = => @model.set phase: 'SUCCESS'
    error   = (e = UNKNOWN_ERROR) => @model.set phase: 'ERROR', error: e

    TableResults.getCache @query
                .fetchRows start, size
                .then (rows) => @fillRowsCollection (rows)
                .then success, error
                .then @model.filled, @model.filled

  # Take the rows returned from somewhere (the cache, usually),
  # and then turn the data into cell models and stuff them in turn
  # into rows.
  fillRowsCollection: (rows) ->
    createModel = @cellModelFactory.getCreator @query
    offset = @model.get 'start'
    # The ID lets us use set for efficient updates.
    models = rows.map (row, i) =>
      id: "#{ @query.toXML() }##{ offset + i }"
      index: (offset + i)
      cells: (createModel c for c in row)

    @rows.set models
    console.log "Loaded #{ models.length } rows, now we have #{ @rows.size() }"

  overlayTable: ->
    return unless @children.inner?.rendered

    table = @children.inner.$el
    elOffset = @$el.offset()
    tableOffset = table.offset()

    @removeOverlay()

    @overlay = document.createElement 'div'
    @overlay.className = 'im-table-overlay im-hidden'

    h1 = @make 'h1', {}, Messages.getText('table.OverlayText')
    h1.style.top = "#{ table.height() / 2 }px"
    @overlay.appendChild h1

    @el.appendChild @overlay

    _.delay (=> @overlay?.classList.remove 'im-hidden'), 100

  removeOverlay: ->
    @el.removeChild @overlay if @overlay?
    delete @overlay

  # Rendering logic
 
  template: -> switch @model.get 'phase'
    when 'FETCHING' then @renderFetching()
    when 'ERROR' then @renderError()
    when 'SUCCESS' then @renderTable()
    else throw new Error "Unknown phase: #{ @model.get 'phase' }"

  # What we render when we are fetching data.
  renderFetching: ->
    Templates.template('table-building') @getBaseData()

  # A helpful and contrite message.
  renderError: ->
    @removeChild 'error'
    @children.error = e = new ErrorNotice {@query, @model}
    e.render().el

  # The actual data table.
  renderTable: ->
    frag = document.createDocumentFragment()

    @renderWidgets frag

    table = new ResultsTable _.extend _.pick(@, ResultsTable::parameters),
      tableState: @model

    @renderChild 'inner', table, frag

    return frag

  # There is some justification for turning the following methods
  # into their own class.
  renderWidgets: (container) ->
    container ?= @el
    widgets = _.chain Options.get 'TableWidgets'
               .map ({enabled, index}, name) -> {name, index, enabled}
               .where enabled: true
               .sortBy 'index'
               .pluck 'name'
               .value()
    
    if widgets.length # otherwise don't bother appending anything.
      widgetDiv = document.createElement 'div'
      widgetDiv.className = 'im-table-controls'
      clear = document.createElement 'div'
      clear.style.clear = 'both'
      for widgetName in widgets when "place#{ widgetName }" of @
        method = "place#{ widgetName }"
        @[ method ]( widgetDiv )
      widgetDiv.appendChild clear
      container.appendChild widgetDiv

  renderWidget: (name, container, Child) ->
    component = new Child {@model, getQuery: => @history.getCurrentQuery()}
    @renderChild name, component, container

  placePagination: (widgets) ->
    @renderWidget 'pagination', widgets, Pagination

  placePageSizer: (widgets) ->
    @renderWidget 'pagesizer', widgets, PageSizer

  placeTableSummary: (widgets) ->
    @renderWidget 'tablesummary', widgets, TableSummary

