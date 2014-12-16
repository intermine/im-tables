_ = require 'underscore'
{Collection} = require 'backbone'
fs = require 'fs'

Messages = require '../messages'
View = require '../core-view'
Model = require '../core-model'
Options = require '../options'
{IS_BLANK} = require '../patterns'

Messages.set
  'multivalue.AddValue': 'Add value'

mustacheSettings = require '../templates/mustache-settings'

valueRow = fs.readFileSync __dirname + '/../templates/value-control-row.html', 'utf8'
html = fs.readFileSync __dirname + '/../templates/add-value-control.html', 'utf8'

class ValueControl extends View

  tagName: 'tr'

  initialize: ->
    @listenTo @model, 'change', @reRender

  events: ->
    'click': 'toggleSelected' # Very broad - want to capture row clicks too.

  toggleSelected: -> @model.toggle 'selected'

  template: _.template valueRow, mustacheSettings

module.exports = class MultiValueControls extends View

  className: 'im-value-options im-multi-value-table'

  initialize: ->
    super
    @values = new Collection
    for v in @model.get('values')
      @values.add new Model value: v, selected: true
    @listenTo @values, 'change:selected add', @updateModel
    @listenTo @values, 'add', @reRender

  events: ->
    'click .im-add': 'addValue'
    'keyup .im-new-multi-value': 'updateNewValue'

  updateNewValue: ->
    @state.set value: @$('.im-new-multi-value').val()

  addValue: (e) ->
    e?.preventDefault()
    e?.stopPropagation()
    value = @state.get 'value'
    if (not value?) or IS_BLANK.test value
      @model.set error: new Error('please enter a value')
      @listenToOnce @state, 'change:value', => @model.unset 'error'
    else
      @values.add new Model {value, selected: true}

  updateModel: ->
    @model.set values: (m.get 'value' for m in @values.where selected: true)

  getData: -> messages: Messages

  template: _.template html

  render: ->
    super
    table = @$ 'table'
    @renderRows table

  renderRows: (container) -> @values.each (m, i) =>
    @renderChild i, (new ValueControl model: m), container

