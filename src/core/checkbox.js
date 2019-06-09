CoreView = require '../core-view'
Templates = require '../templates'
Messages = require '../messages'

# Optimised checkbox component, that does not do
# full-re-renders, and can avoid re-rendering in
# its parent component.
module.exports = class Checkbox extends CoreView

  class: 'checkbox'

  template: Templates.template 'checkbox'

  getData: ->
    checked: @checked()
    label: (if @label then Messages.getText(@label) else null)

  initialize: ({@attr, @label}) -> super

  checked: -> @model.get @attr

  toggle: (e) ->
    e?.stopPropagation()
    @model.toggle @attr

  events: ->
    'click': 'toggle'

  modelEvents: ->
    evts = {}
    evts["change:#{ @attr }"] = @setCheckboxState
    return evts

  setCheckboxState: ->
    @cb ?= @$('input')[0]
    @cb.checked = @model.get @attr

