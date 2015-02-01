_ = require 'underscore'

CoreView = require '../core-view'
Messages = require '../messages'
Modal = require './modal'
Body = require './join-manager/body'
Joins = require '../models/joins'

require '../messages/joins'

module.exports = class FilterDialogue extends Modal

  parameters: ['query']

  modalSize: -> 'lg'

  className: -> super + ' im-join-manager'

  title: -> Messages.getText 'joins.Heading'
  dismissAction: -> Messages.getText 'Cancel'
  primaryAction: -> Messages.getText 'modal.ApplyChanges'

  initialize: ->
    super
    @joins = Joins.fromQuery @query

  act: -> throw new Error 'TODO'

  postRender: ->
    super
    body = @$ '.modal-body'
    @renderChild 'cons', (new Body collection: @joins), body

