CoreView = require '../core-view'
Templates = require '../templates'
Step = require './undo-history/step'

childId = (s) -> "state-#{ s.get('revision') }" 

module.exports = class UndoHistory extends CoreView

  parameters: ['collection']

  className: 'btn-group im-undo-history'

  template: Templates.template 'undo-history'

  postRender: ->
    @$list = @$ '.im-state-list'
    for i in [@collection.length - 1 .. 0]
      @renderState @collection.at i
    @$el.toggleClass 'im-has-history', @collection.size() > 1
    @$el.toggleClass 'im-hidden', @collection.size() <= 1

  renderState: (s) ->
    @renderChild (childId s), (new Step model: s), @$list

