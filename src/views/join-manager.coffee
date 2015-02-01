_ = require 'underscore'

CoreView = require '../core-view'
Messages = require '../messages'
Modal = require './modal'
Body = require './join-manager/body'
Joins = require '../models/joins'

require '../messages/joins'

# Simple flat array equals
areEql = (xs, ys) ->
  (xs.length is ys.length) and (_.all xs, (x, i) -> x is ys[i])

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
    @listenTo @joins, 'change:style', @setDisabled

  initState: ->
    @state.set disabled: true

  act: -> unless @state.get('disabled')
    newJoins = @joins.getJoins()
    @query.joins = newJoins
    @query.trigger 'change:joins', newJoins
    @resolve newJoins

  setDisabled: ->
    current = _.keys @joins.getJoins()
    initial = (p for p, s of @query.joins when s is 'OUTER')
    current.sort()
    initial.sort()
    @state.set disabled: (areEql current, initial)

  postRender: ->
    super
    body = @$ '.modal-body'
    @renderChild 'cons', (new Body collection: @joins), body

