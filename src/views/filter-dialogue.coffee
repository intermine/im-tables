_ = require 'underscore'

CoreView = require '../core-view'
Modal = require './modal'
Messages = require '../messages'
Templates = require '../templates'

Constraints = require './constraints'

require '../messages/constraints'
require '../messages/logic'

class LogicManager extends CoreView

  className: 'form im-evenly-spaced im-constraint-logic'
  tagName: 'form'

  template: Templates.template('logic-manager-body')

  parameters: ['query']

  initialize: ->
    super
    codes = (c.code for c in @query.constraints when c.code)
    @model.set logic: @query.constraintLogic
    @state.set disabled: true, defaultLogic: codes.join ' and '

  events: ->
    'change .im-logic': @setLogic
    'submit': @applyChanges

  modelEvents: ->
    'change:logic': @setDisabled

  stateEvents: ->
    'change:disabled': @reRender

  setDisabled: ->
    newLogic = @model.get('logic')
    current = @query.constraintLogic
    @state.set disabled: (newLogic is current)

  setLogic: (e) ->
    @model.set logic: e.target.value

  applyChanges: (e) ->
    e?.preventDefault()
    e?.stopPropagation()
    unless @state.get('disabled')
      newLogic = @model.get('logic')
      @query.constraintLogic = newLogic
      @query.trigger 'change:logic', newLogic

class Body extends Constraints

  template: Templates.template 'active-constraints'

  initialize: ->
    super
    @assignCodes()

  stateEvents: ->
    'change:adding': @reRender

  CODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  assignCodes: ->
    constraints = (c for c in @query.constraints when c.op?)
    return if constraints.length < 2
    codes = CODES.split('') # New array each time.
    for c in constraints when not c.code?
      while not c.code? and (code = codes.shift())
        c.code = code unless (_.any constraints, (con) -> con.code is code)

  postRender: ->
    super
    constraints = @getConstraints()
    if constraints.length > 1
      @renderChild 'logic', new LogicManager {@query}
    mth = if @state.get('adding') then 'slideUp' else 'slideDown'
    @$('.im-current-constraints')[mth] 400

  getConAdder: -> super if @state.get 'adding'

module.exports = class FilterDialogue extends Modal

  parameters: ['query']

  modalSize: -> 'lg'

  className: -> super + ' im-filter-manager'

  title: -> Messages.getText 'constraints.Heading', n: @query.constraints.length

  initState: ->
    @state.set adding: false, disabled: false

  act: ->
    @state.set adding: true, disabled: true

  dismissAction: -> Messages.getText 'Cancel'
  primaryAction: -> Messages.getText 'constraints.DefineNew'

  initialize: ->
    super
    @listenTo @, 'shown', @renderBodyContent
    @listenTo @query, 'change:constraints', @onChangeConstraints

  onChangeConstraints: ->
    @initState()
    @renderTitle()

  renderBodyContent: -> if @shown
    body = @$ '.modal-body'
    _.defer => @renderChild 'cons', (new Body {@state, @query}), body


