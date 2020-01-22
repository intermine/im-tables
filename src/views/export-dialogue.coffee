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
FastaOptions = require './export-dialogue/fasta-options'
DestinationOptions = require './export-dialogue/destination-options'
Preview = require './export-dialogue/preview'

openWindowWithPost = require '../utils/open-window-with-post'
sendToDropBox = require '../utils/send-to-dropbox'
sendToGoogleDrive = require '../utils/send-to-google-drive'
sendToGalaxy = require '../utils/send-to-galaxy'

INITIAL_STATE =
  doneness: null # null = not uploading. 0 - 1 = uploading
  tab: 'dest'
  dest: 'download'
  linkToFile: null

FOOTER = ['progress_bar', 'modal_error', 'export_dialogue_footer']

# The errors users cannot just dismiss, but have to do something to make
# go away.
class UndismissableError

  cannotDismiss: true

  constructor: (key) ->
    @key = 'export.error.' + key
    @message = Messages.get @key

# The model backing this view.
class ExportModel extends Model

  # The different attributes that define the data we care about.
  defaults: ->
    filename: 'results'
    format: Formats.getFormat('tab') # Should be one of the Formats
    tablePage: null # or {start :: int, size :: int}
    start: 0
    columns: []
    size: null
    max: null
    compress: false
    compression: 'gzip'
    headers: false
    jsonFormat: 'rows'
    fastaExtension: null
    headerType: 'friendly'

isa = (target) -> (path) -> path.isa target

# A complex dialogue that delegates the configuration of different
# export parameters to subviews.
module.exports = class ExportDialogue extends Modal

  @include RunsQuery

  Model: ExportModel

  className: -> 'im-export-dialogue ' + super

  parameters: ['query']

  initialize: ->
    super
    # Lift format to definition if supplied.
    if (@model.has 'format') and not (@model.get('format').ext)
      @model.set format: Formats.getFormat @model.get 'format'
    @state.set INITIAL_STATE
    @listenTo @state, 'change:tab', @renderMain
    @listenTo @model, 'change', @updateState
    @listenTo @model, 'change:columns', @setMax
    @listenTo @model, 'change:format', @onChangeFormat
    @categoriseQuery()
    @model.set columns: @query.views
    @model.set filename: @query.name.replace(/\s+/g, '_') if @query.name?
    @updateState()
    @setMax()
    @readUserPreferences()

  onChangeFormat: -> _.defer =>
    format = @model.get 'format'
    activeCols = @model.get 'columns'
    if format.needs?.length
      oldColumns = activeCols.slice()
      newColumns = []
      for v in @query.views
        p = @query.makePath(v).getParent()
        if (_.any format.needs, (needed) -> p.isa(needed))
          newColumns.push p.append('id').toString()
      nodecolumns = _.uniq(newColumns)
      @model.set nodecolumns: nodecolumns
      maxCols = format.maxColumns
      cs = if maxCols then _.first(nodecolumns, maxCols) else nodecolumns.slice()
      @model.set columns: cs
      @model.once 'change:format', =>
        @model.set columns: oldColumns
        @model.unset 'nodecolumns'

  # Read any relevant preferences into state/Options.
  readUserPreferences: -> @query.service.whoami().then (user) =>
    return unless user.hasPreferences
    
    if (myGalaxy = user.preferences['galaxy-url'])
      Options.set 'Destination.Galaxy.Current', myGalaxy

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
  footer: Templates.templateFromParts FOOTER

  updateState: ->
    {compress, compression, start, size, max, format, columns} = @model.toJSON()

    columnDesc = if _.isEqual(columns, @query.views)
      Messages.get('All')
    else
      columns.length

    rowCount = @getRowCount()

    error = if columns.length is 0
      new UndismissableError 'NoColumnsSelected'
    else if start >= max
      new UndismissableError 'OffsetOutOfBounds'
    else
      null

    @state.set @model.pick 'headers', 'headerType', 'jsonFormat', 'fastaExtension'
    @state.set
      error: error
      format: format
      max: max
      exportURI: @getExportURI()
      rowCount: @getRowCount()
      compression: (if compress then compression else null)
      columns: columnDesc

  getRowCount: ->
    {start, size, max} = @model.pick 'start', 'size', 'max'
    start ?= 0 # Should always be a number, but do check
    max -= (start ? 0) # Reduce the absolute maximum by the offset.
    size = (if size? and size > 0 then size else max) # Make sure size is not 0 or null.
    Math.min max, size

  getMain: ->
    switch @state.get('tab')
      when 'format' then FormatControls
      when 'columns' then ColumnControls
      when 'compression' then CompressionControls
      when 'column-headers' then FlatFileOptions
      when 'opts-json' then JSONOptions
      when 'opts-fasta' then FastaOptions
      when 'dest' then DestinationOptions
      when 'rows' then RowControls
      when 'preview' then Preview
      else FormatControls

  onUploadComplete: (link) =>
    @state.set doneness: null, linkToFile: link

  onUploadProgress: (doneness) => @state.set {doneness}

  onUploadError: (err) =>
    @state.set doneness: null, error: err
    console.error err

  act: ->
    @onUploadProgress 0
    # exporter is a function: (string, string, fn) -> Promise<string>
    exporter = @getExporter()
    # The @ context of an exporter is {model, state, query}
    {model, state, query} = @
    # But it gets read-only versions of them.
    ctx = {model: model.toJSON(), state: state.toJSON(), query: query.clone()}
    # The parameters are:
    uri = @getExportURI()          #:: string
    file = @getFileName()          #:: string
    onProgress = @onUploadProgress #:: (number) ->
    exporting = exporter.call ctx, uri, file, onProgress
    exporting.then @onUploadComplete, @onUploadError

    # Exports can have after actions.
    if exporter.after?
      postExport = exporter.after.bind ctx
      exporting.then(postExport, postExport).then null, (e) => @state.set error: e

  getExporter: -> switch @state.get 'dest'
    when 'download' then -> Promise.resolve null # Download handled by use of an <a/>
    when 'Dropbox' then sendToDropBox
    when 'Drive' then sendToGoogleDrive
    when 'Galaxy' then sendToGalaxy
    else throw new Error "Cannot export to #{ @state.get 'dest' }"

  events: ->
    evts = super
    evts.keyup = 'handleKeyup'
    return evts

  handleKeyup: (e) ->
    return if @$(e.target).is 'input'
    switch e.which
      when 40 then @children.menu?.next()
      when 38 then @children.menu?.prev()

  renderMain: ->
    Main = @getMain()
    @renderChild 'main', (new Main {@model, @query, @state}), @$ 'div.main'

  postRender: ->
    @renderChild 'menu', (new Menu {model: @state}), @$ 'nav.menu'
    @renderMain()
    @$el.focus() # to enable keyboard navigation
    super
