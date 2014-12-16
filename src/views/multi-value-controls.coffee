_ = require 'underscore'
{Collection} = require 'backbone'
fs = require 'fs'

Messages = require '../messages'
Icons = require '../icons'
View = require '../core-view'
Model = require '../core-model'
Options = require '../options'
{IS_BLANK} = require '../patterns'

Messages.set
  'multivalue.AddValue': 'Add value'
  'multivalue.SaveValue': 'Save changes'

mustacheSettings = require '../templates/mustache-settings'

valueRow = fs.readFileSync __dirname + '/../templates/value-control-row.html', 'utf8'
html = fs.readFileSync __dirname + '/../templates/add-value-control.html', 'utf8'

class ValueControl extends View

  tagName: 'tr'

  initialize: ->
    @model.set editing: false, scratch: @model.get('value')
    @listenTo @model, 'change:editing change:value change:selected', @reRender

  events: ->
    'click .input-group': (e) -> e?.stopPropagation()
    'click .im-edit': 'editValue'
    'keyup input': 'updateScratch'
    'change input': 'updateScratch'
    'click .im-save': 'saveValue'
    'click .im-cancel': 'cancelEditing'
    'click': 'toggleSelected' # Very broad - want to capture row clicks too.

  updateScratch: (e) ->
    e?.stopPropagation()
    @model.set scratch: e.target.value

  saveValue: (e) ->
    e?.stopPropagation()
    @model.set editing: false, value: @model.get('scratch')

  cancelEditing: (e) ->
    e?.stopPropagation()
    @model.set editing: false, scratch: @model.get('value')

  editValue: (e) ->
    e?.stopPropagation()
    @model.toggle 'editing'

  toggleSelected: -> @model.toggle 'selected'

  getData: -> _.extend {icons: Icons, messages: Messages}, @model.toJSON()

  template: _.template valueRow, mustacheSettings

module.exports = class MultiValueControls extends View

  className: 'im-value-options im-multi-value-table'

  initialize: ->
    super
    @values = new Collection
    for v in (@model.get('values') or [])
      @values.add new Model value: v, selected: true
    @listenTo @values, 'change:selected change:value add', @updateModel
    @listenTo @values, 'add reset', @reRender

    # Help translate between multi-value and =
    @listenTo @model, 'change:values', =>
      were = @model.previous 'values'
      unless were? # Allow to be reset with new values.
        @values.reset(new Model value: v, selected: true for v in @model.get 'values')
    @listenTo @model, 'change:op', =>
      newOp = @model.get 'op'
      if newOp in ['=', '!='] and (not @model.has 'value')
        @model.set values: null, value: @values.first().get('value')

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

