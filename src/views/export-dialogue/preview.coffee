_ = require 'underscore'

CoreView = require '../../core-view'
Messages = require '../../messages'
Templates = require '../../templates'

RunsQuery = require '../../mixins/runs-query'

module.exports = class Preview extends CoreView

  @include RunsQuery

  initialize: ({@query}) ->
    super
    @state.set preview: ''
    @setPreview()
    @listenTo @state, 'change:preview', @reRender
    @listenTo @model, 'change', @setPreview

  setPreview: -> @runQuery(size: 3).then (resp) =>
    if _.isString(resp)
      @state.set preview: resp
    else
      @state.set preview: (JSON.stringify resp, null, 2)

  template: Templates.template 'export_preview'

