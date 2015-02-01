_ = require 'underscore'

CoreView = require '../core-view'
Modal = require './modal'
Messages = require '../messages'
Templates = require '../templates'

Constraints = require './constraints'

require '../messages/constraints'

class Body extends Constraints

  template: Templates.template 'active-constraints'

  stateEvents: ->
    'change:adding': @reRender

  postRender: ->
    super
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


