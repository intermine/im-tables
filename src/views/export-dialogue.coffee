_ = require 'underscore'
$ = require 'jquery'

Model = require '../core-model'
Modal = require './modal'
ConstraintAdder = require './constraint-adder'
Messages = require '../messages'
Templates = require '../templates'
Options = require '../options'

Formats = require '../models/export-formats'
RunsQuery = require '../mixins/runs-query'
Menu = require './export-dialogue/tab-menu'
FormatControls = require './export-dialogue/format-controls'
RowControls = require './export-dialogue/row-controls'
ColumnControls = require './export-dialogue/column-controls'
CompressionControls = require './export-dialogue/compression-controls'
FlatFileOptions = require './export-dialogue/flat-file-options'
JSONOptions = require './export-dialogue/json-options'
DestinationOptions = require './export-dialogue/destination-options'
Preview = require './export-dialogue/preview'

openWindowWithPost = require '../utils/open-window-with-post'
sendToDropBox = require '../utils/send-to-dropbox'
sendToGoogleDrive = require '../utils/send-to-google-drive'

downloadFile = (uri, fileName) ->
  openWindowWithPost uri, '__not_important__', {fileName}
  Promise.resolve true

INITIAL_STATE =
  doneness: null # null = not uploading. 0 - 1 = uploading
  tab: 'dest'
  dest: 'download'
  linkToFile: null

class ExportModel extends Model

  defaults: ->
    name: 'results'
    format: Formats.getFormat('tab')
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

  @include RunsQuery

  Model: ExportModel

  className: -> 'im-export-dialogue ' + super

  initialize: ({@query}) ->
    super
    @state.set INITIAL_STATE
    @listenTo @state, 'change:tab', @renderMain
    @listenTo @model, 'change', @updateState
    @listenTo @model, 'change:columns', @setMax
    @categoriseQuery()
    @model.set columns: @query.views
    @model.set name: @query.name.replace(/\s+/g, '_') if @query.name?
    @updateState()
    @setMax()

  setMax: -> @getEstimatedSize().then (c) => @model.set max: c

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

  primaryAction: -> Messages.getText @state.get 'dest'

  primaryIcon: -> @state.get 'dest'

  body: Templates.template 'export_dialogue'

  # In some future universe we would have template inheritance here,
  # but that is a hack to fake in underscore templates
  footer: Templates.template 'export_dialogue_footer'

  updateState: ->
    {compress, compression, start, size, max, format, columns} = @model.toJSON()

    columnDesc = if _.isEqual(columns, @query.views)
      Messages.get('All')
    else
      columns.length

    # Establish the error state. TODO - use Message.getText
    error = if columns.length is 0
      {message: 'No columns selected'}
    else if start >= max
      {message: 'Offset is greater than the number of results'}
    else
      null

    # TODO: need a better calculation for rowCount
    @state.set @model.pick 'headers', 'headerType', 'jsonFormat'
    @state.set
      exportURI: @getExportURI()
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
      when 'dest' then DestinationOptions
      when 'rows' then RowControls
      when 'preview' then Preview
      else FormatControls

  onUploadComplete: (link) =>
    @state.set doneness: null, linkToFile: link

  onUploadProgress: (doneness) => @state.set {doneness}

  onUploadError: (err) =>
    @state.set doneness: null, err: err
    console.error err

  getFileExtension: -> @model.get('format').ext

  getBaseName: -> @model.get 'name'

  getFileName: -> "#{ @getBaseName() }.#{ @getFileExtension() }"

  act: ->
    @onUploadProgress 0
    exporter = @getExporter()
    uploading = exporter(@getExportURI(), @getFileName(), @onUploadProgress)
    uploading.then @onUploadComplete, @onUploadError

  getExporter: -> switch @state.get 'dest'
    when 'download' then -> Promise.resolve null
    when 'Dropbox' then sendToDropBox
    when 'Drive' then sendToGoogleDrive
    when 'Galaxy' then throw new Error 'not implemented'
    when 'GenomeSpace' then throw new Error 'not implemented'
    else throw new Error "Cannot export to #{ @state.get 'dest' }"

  renderMain: ->
    Main = @getMain()
    @renderChild 'main', (new Main {@model, @query, @state}), @$ 'div.main'

  postRender: ->
    @renderChild 'menu', (new Menu {model: @state}), @$ 'nav.menu'
    @renderMain()
    super
