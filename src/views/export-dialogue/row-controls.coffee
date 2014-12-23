_ = require 'underscore'
View = require '../../core-view'
LabelView = require '../label-view'
Messages = require '../../messages'
Templates = require '../../templates'

class SizeLabel extends LabelView

  getData: -> size: (@model.get('size') or Messages.getText('rows.All'))

  template: _.partial Messages.getText, 'export.param.Size'

class OffsetLabel extends LabelView

  template: _.partial Messages.getText, 'export.param.Start'

class HeadingLabel extends LabelView

  template: _.partial Messages.getText, 'export.category.Rows'

class ResetButton extends View

  RERENDER_EVENT: 'change'

  getData: -> _.extend super, isAll: not (@model.get('start') or @model.get('size'))

  template: Templates.template 'export_rows_reset_button'

  events: ->
    'click button': 'reset'

  reset: ->
    @model.set start: 0, size: null

module.exports = class RowControls extends View

  RERENDER_EVENT: 'change:max'

  initialize: ({state}) ->
    super
    @model.set max: null unless @model.has 'max'
    @listenTo @model, 'change:size', @updateLabels
    @listenTo @model, 'change:size change:start', @updateInputs
    @parentState = state # Don't write to this.

  tagName: 'form'

  template: Templates.template 'export_row_controls'

  events: ->
    'input input[name=size]': 'onChangeSize'
    'input input[name=start]': 'onChangeStart'

  updateInputs: ->
    {start, size, max} = @model.toJSON()
    @$("input[name=size]").val (size or max)
    @$("input[name=start]").val start

  onChangeSize: ->
    size = parseInt(@$('input[name=size]').val(), 10)
    if (not size) or (size is @model.get('max'))
      @model.set size: null
    else
      @model.set size: size

  onChangeStart: ->
    @model.set start: parseInt(@$('input[name=start]').val(), 10)

  postRender: ->
    @renderChild 'heading', (new HeadingLabel model: @parentState), @$ 'h3'
    @renderChild 'size', (new SizeLabel {@model}), @$ '.size-label'
    @renderChild 'start', (new OffsetLabel {@model}), @$ '.start-label'
    @renderChild 'reset', (new ResetButton {@model}), @$ '.im-reset'

