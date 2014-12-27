_ = require 'underscore'

Model = require '../core-model'
Modal = require './modal'
ConstraintAdder = require './constraint-adder'
Messages = require '../messages'
Templates = require '../templates'

Menu = require './export-dialogue/tab-menu'
FormatControls = require './export-dialogue/format-controls'
RowControls = require './export-dialogue/row-controls'
ColumnControls = require './export-dialogue/column-controls'
CompressionControls = require './export-dialogue/compression-controls'
FlatFileOptions = require './export-dialogue/flat-file-options'
JSONOptions = require './export-dialogue/json-options'

class ExportModel extends Model

  defaults: ->
    format: 'tsv'
    start: 0
    columns: []
    size: null
    max: null
    compress: false
    compression: 'gzip'
    headers: false
    jsonFormat: 'rows'
    headerType: 'friendly'

isa = (target) -> (path) -> path.isa target

# A complex dialogue that delegates the configuration of different
# export parameters to subviews.
module.exports = class ExportDialogue extends Modal

  Model: ExportModel

  className: -> 'im-export-dialogue ' + super

  initialize: ({@query}) ->
    super
    @state.set tab: 'format', dest: 'FAKE DATA'
    @listenTo @state, 'change:tab', @renderMain
    @listenTo @model, 'change', @updateState
    @query.count().then (c) => @model.set max: c
    @categoriseQuery()
    @model.set columns: @query.views
    @updateState()

  # This is probably slight overkill, and could be replaced
  # with a function at the cost of complexity. On the plus side, it
  # does not seem to impact performance, and is run only once.
  categoriseQuery: ->
    viewNodes = @query.getViewNodes()
    has = {}
    for type, table of @query.model.classes
      has[type] = _.any viewNodes, isa type
    @model.set {has}

  title: -> Messages.getText 'ExportTitle', {name: @query.name}

  modalSize: 'lg'

  primaryAction: -> Messages.getText 'ExportButton'

  body: Templates.template 'export_dialogue'

  updateState: ->
    {compress, compression, start, size, max, format, columns} = @model.toJSON()

    columnDesc = if _.isEqual(columns, @query.views)
      Messages.get('All')
    else
      columns.length

    # Establish the error state.
    error = if columns.length is 0
      {message: 'No columns selected'}
    else
      null

    # TODO: need a better calculation for rowCount
    @state.set @model.pick 'headers', 'headerType'
    @state.set
      compression: (if compress then compression else null)
      error: error
      format: format
      max: @model.get('max')
      rowCount: ((size or (max - start)) or max)
      columns: columnDesc

  getMain: ->
    switch @state.get('tab')
      when 'format' then FormatControls
      when 'columns' then ColumnControls
      when 'compression' then CompressionControls
      when 'column-headers' then FlatFileOptions
      when 'opts-json' then JSONOptions
      when 'rows' then RowControls
      else FormatControls

  renderMain: ->
    Main = @getMain()
    @renderChild 'main', (new Main {@model, @query, @state}), @$ 'div.main'

  postRender: ->
    @renderChild 'menu', (new Menu {model: @state}), @$ 'nav.menu'
    @renderMain()
    super
