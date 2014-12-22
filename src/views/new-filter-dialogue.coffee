_ = require 'underscore'

Modal = require './modal'
ConstraintAdder = require './constraint-adder'
Templates = require '../templates'
Messages = require '../messages'

# Very simple dialogue that just wraps a ConstraintAdder
module.exports = class NewFilterDialogue extends Modal

  className: -> 'im-constraint-dialogue ' + super

  modalSize: 'modal-lg'

  initialize: ({@query}) ->
    super
    @listenTo @query, 'change:constraints', @resolve # Our job is done.
    @listenTo @query, 'editing-constraint', => # Can we do this on the model?
        @$('.im-add-constraint').removeClass 'disabled'

  events: -> _.extend super,
    'click .im-add-constraint': 'addConstraint'
    'childremoved': (e, child) => @hide() if child instanceof ConstraintAdder

  title: -> Messages.getText 'constraints.AddNewFilter'
  primaryAction: -> Messages.getText 'constraints.AddFilter'

  postRender: ->
    @renderChild 'adder', (new ConstraintAdder {@query}), @$ '.modal-body'
    super
