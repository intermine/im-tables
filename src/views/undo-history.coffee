_ = require 'underscore'
CoreView = require '../core-view'
Templates = require '../templates'
Messages = require '../messages'
Options = require '../options'
Step = require './undo-history/step'

childId = (s) -> "state-#{ s.get('revision') }" 

ELLIPSIS = -1

require '../messages/undo'

class Ellipsis extends CoreView

  parameters: ['more']

  tagName: 'li'

  className: 'im-step im-ellipsis'

  template: -> _.escape "#{ Messages.getText 'undo.MoreSteps', {@more} } ..."

  attributes: -> title: Messages.getText('undo.ShowAllStates', n: @more)

  postRender: -> @$el.tooltip placement: 'right'

  events: -> click: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @state.toggle 'showAll'

# A step is not trivial is its count differs from the step before it
# (i.e. it introduced some significant change that changed the results).
# The first and last models are always significant.
notTrivial = (m, i, ms) ->
  prev = ms[i - 1]
  (i is 0) or (i is ms.length - 1) or (m.get('count') isnt prev.get('count'))

module.exports = class UndoHistory extends CoreView

  parameters: ['collection']

  className: 'btn-group im-undo-history'

  template: Templates.template 'undo-history'

  events: ->
    'click .btn.im-undo': 'revertToPreviousState'
    'click .im-toggle-trivial': 'toggleTrivial'

  initState: ->
    @state.set showAll: false, hideTrivial: false

  stateEvents: ->
    'change:showAll': @reRender
    'change:hideTrivial': @reRender

  collectionEvents: ->
    remove: @removeStep
    'add remove': @reRender
    'change:count': @reRenderIfHidingTrivial

  toggleTrivial: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @state.toggle 'hideTrivial'

  revertToPreviousState: -> @collection.popState()

  reRenderIfHidingTrivial: -> if @state.get 'hideTrivial'
    @reRender()

  postRender: ->
    @$('.im-toggle-trivial').tooltip placement: 'right'
    @$list = @$ '.im-state-list'
    @renderStates()
    @$el.toggleClass 'im-has-history', @collection.size() > 1
    @$el.toggleClass 'im-hidden', @collection.size() <= 1

  renderStates: ->
    {showAll, hideTrivial} = @state.toJSON()
    coll = @collection
    models = if hideTrivial
      coll.filter notTrivial
    else
      coll.models.slice() # With low level access comes great responsibility.
    states = models.length
    cutoff = Options.get('UndoHistory.ShowAllStatesCutOff')
    range = if (showAll) or (states <= cutoff)
      [states - 1 .. 0]
    else
      [states - 1 .. states - (cutoff - 1)].concat [ELLIPSIS, 0]

    for i in range
      if i is ELLIPSIS
        @renderEllipsis states - cutoff
      else
        @renderState models[i]

  renderEllipsis: (more) ->
    @renderChild '...', (new Ellipsis {more, @state}), @$list

  renderState: (s) ->
    @renderChild (childId s), (new Step model: s), @$list

  removeStep: (s) ->
    @removeChild childId s

