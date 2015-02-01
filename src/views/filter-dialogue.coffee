_ = require 'underscore'

CoreView = require '../core-view'
Modal = require './modal'
Messages = require '../messages'
Templates = require '../templates'

Constraints = require './constraints'

require '../messages/constraints'

class ConAdderButton extends CoreView

  tagName: 'button'

  className: 'btn btn-primary im-add-constraint'

  template: -> _.escape Messages.getText 'constraints.DefineNew'

class Body extends Constraints

  template: Templates.template 'active-constraints'

  getConAdder: -> new ConAdderButton

module.exports = class FilterDialogue extends Modal

  parameters: ['query']

  modalSize: -> 'lg'

  className: -> super + ' im-filter-manager'

  title: -> Messages.getText 'constraints.Heading', n: @query.constraints.length

  dismissAction: -> Messages.getText 'Cancel'

  initialize: ->
    super
    @listenTo @, 'shown', @renderBodyContent

  renderBodyContent: -> if @shown
    body = @$ '.modal-body'
    _.defer => @renderChild 'cons', (new Body query: @query.clone()), body


