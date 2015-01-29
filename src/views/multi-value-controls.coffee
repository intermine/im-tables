_ = require 'underscore'
{Collection} = require 'backbone'

Messages = require '../messages'
Templates = require '../templates'
Icons = require '../icons'
View = require '../core-view'
Model = require '../core-model'
Collection = require '../core/collection'
Options = require '../options'
{IS_BLANK} = require '../patterns'
{ignore} = require '../utils/events'

Messages.set
  'multivalue.AddValue': 'Add value'
  'multivalue.SaveValue': 'Save changes'

mustacheSettings = require '../templates/mustache-settings'

class ValueModel extends Model

  defaults: ->
    editing: false
    scratch: null
    selected: true

  idAttribute: 'value'

class Values extends Collection

  model: ValueModel

class ValueControl extends View

  Model: ValueModel

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
    ignore e
    @model.set scratch: e.target.value

  # scratch value becomes real value. Editing stops.
  saveValue: (e) ->
    ignore e
    @model.set editing: false, value: @model.get('scratch')

  # reset scratch value with real value. Editing stops.
  cancelEditing: (e) ->
    ignore e
    @model.set editing: false, scratch: @model.get('value')

  editValue: (e) ->
    ignore e
    @model.toggle 'editing'

  toggleSelected: (e) ->
    ignore e
    @model.toggle 'selected'

  getData: -> _.extend {icons: Icons, messages: Messages}, @model.toJSON()

  template: Templates.template 'value-control-row', mustacheSettings

module.exports = class MultiValueControls extends View

  className: 'im-value-options im-multi-value-table'

  initialize: ->
    super
    @values = new Values
    for v in (@model.get('values') or [])
      @values.add value: v
    @listenTo @values, 'change:selected change:value add', @updateModel
    @listenTo @values, 'add', @renderValue
    @listenTo @values, 'remove', @removeValue

  stateEvents: ->
    'change:value': @onChangeNewValue

  # Help translate between multi-value and =
  # changing the op elsewhere triggers this controller to change the
  # value(s).
  modelEvents: ->
    'change:op': @onChangeOp
    'change:values': @onChangeValues

  onChangeValues: ->
    # We only need to reset if transitioning from non-multi constraint.
    return if @model.previous('values')?
    current = @model.get 'values'
    @values.set({value} for value in (current ? []))

  onChangeOp: ->
    newOp = @model.get 'op'
    if newOp in ['=', '!='] and (not @model.has 'value')
      @model.set values: null, value: @values.first().get('value')

  events: ->
    'keyup .im-new-multi-value': @updateNewValue
    'click .im-add': @addValue

  # Two-way binding between state.value and .im-new-multi-value
  onChangeNewValue: ->
    @$('.im-new-multi-value').val @state.get 'value'

  updateNewValue: ->
    @state.set value: @$('.im-new-multi-value').val()

  addValue: (e) ->
    ignore e
    value = @state.get 'value'
    if (not value?) or IS_BLANK.test value
      @model.set error: new Error('please enter a value')
      @listenToOnce @state, 'change:value', => @model.unset 'error'
    else
      @values.add {value}
      @state.unset 'value'

  updateModel: ->
    @model.set values: (m.get 'value' for m in @values.where selected: true)

  getData: -> messages: Messages

  template: Templates.template 'add-value-control'

  postRender: ->
    @$table = @$ 'table'
    @renderRows()

  renderRows: -> @values.each (m) => @renderValue m

  removeValue: -> @removeChild m.id

  renderValue: (m) ->
    @renderChild m.id, (new ValueControl model: m), @$table

  remove: ->
    @values.close()
    super

