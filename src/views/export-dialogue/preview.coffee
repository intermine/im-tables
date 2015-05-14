_ = require 'underscore'

CoreView = require '../../core-view'
Messages = require '../../messages'
Templates = require '../../templates'
Formats = require '../../models/export-formats'

RunsQuery = require '../../mixins/runs-query'

PROPS =
  compress: null # HTTP gzip will still take place.
  size: 3

module.exports = class Preview extends CoreView

  @include RunsQuery

  initialize: ({@query}) ->
    super
    @state.set preview: ''
    @setPreview()
    @listenTo @state, 'change:preview', @reRender
    @listenTo @model, 'change:format', @setPreview

  setPreview: ->
    format = @model.get('format')
    if format.group is 'bio'
      # bio formats to not support paging, and so we can kill the
      # browser by requesting too much data.
      @state.set preview: 'Previews are not supported for bio-informatics formats'
    else
      @runQuery(PROPS).then (resp) =>
        if _.isString(resp)
          @state.set preview: resp
        else
          @state.set preview: (JSON.stringify resp, null, 2)

  template: Templates.template 'export_preview'

  getData: ->
    types = @model.get 'has'
    formats = Formats.getFormats types
    _.extend {formats}, super

  events: ->
    'change .im-export-formats select': 'setFormat'

  setFormat: (e) -> @model.set format: Formats.getFormat e.target.value

