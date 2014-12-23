_ = require 'underscore'
View = require '../../core-view'
Messages = require '../../messages'
Templates = require '../../templates'
LabelView = require '../label-view'
Formats = require '../../models/export-formats'

class HeadingView extends LabelView

  template: _.partial Messages.getText, 'export.category.Format'

module.exports = class FormatControls extends View

  tagName: 'form'

  template: Templates.template 'export_format_controls'

  getData: ->
    types = @model.get 'has'
    formats = Formats.getFormats types
    _.extend {formats}, super

  events: ->
    'change input:radio': 'onChangeFormat'

  onChangeFormat: ->
    @model.set format: @$('input:radio:checked').val()

  postRender: ->
    @renderChild 'heading', (new HeadingView {@model}), @$ 'h3'

