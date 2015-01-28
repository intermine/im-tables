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

  template: -> '...'

  attributes: -> title: Messages.getText('undo.ShowAllStates', n: @more)

  postRender: -> @$el.tooltip placement: 'right'

  events: -> click: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @state.toggle 'showAll'

module.exports = class UndoHistory extends CoreView

  parameters: ['collection']

  className: 'btn-group im-undo-history'

  template: Templates.template 'undo-history'

  events: ->
    'click .btn.im-undo': 'revertToPreviousState'

  initState: ->
    @state.set showAll: false

  stateEvents: ->
    'change:showAll': @reRender

  collectionEvents: ->
    remove: @removeStep
    'add remove': @reRender

  revertToPreviousState: -> @collection.popState()

  postRender: ->
    @$list = @$ '.im-state-list'
    states = @collection.length
    cutoff = Options.get('UndoHistory.ShowAllStatesCutOff')
    range = if (@state.get 'showAll') or (states <= cutoff)
      [states - 1 .. 0]
    else
      [states - 1 .. states - (cutoff - 1)].concat [ELLIPSIS, 0]

    for i in range
      if i is ELLIPSIS
        @renderEllipsis states - cutoff
      else
        @renderState @collection.at i
    @$el.toggleClass 'im-has-history', @collection.size() > 1
    @$el.toggleClass 'im-hidden', @collection.size() <= 1

  renderEllipsis: (more) ->
    @renderChild '...', (new Ellipsis {more, @state}), @$list

  renderState: (s) ->
    @renderChild (childId s), (new Step model: s), @$list

  removeStep: (s) ->
    @removeChild childId s

