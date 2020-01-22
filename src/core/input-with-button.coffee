_ = require 'underscore'
CoreView = require '../core-view'
Templates = require '../templates'

# Component that represents an input with an appended
# button. This component keeps the model value in sync
# with the displayed DOM value, and emits an 'act' event
# when the button is clicked.
module.exports = class InputWithButton extends CoreView

  className: 'input-group'

  template: Templates.template 'input-with-button'

  getData: -> _.extend @getBaseData(),
    value: @model.get @sets
    placeholder: @placeholder
    button: @button

  # If passed in with a model, then we set into that,
  # otherwise maintain our own model value.
  initialize: ({@placeholder, @button, @sets}) ->
    super
    @sets ?= 'value'

  postRender: ->
    @$el.addClass @className

  modelEvents: ->
    e = {}
    e["change:#{ @sets }"] = @setDomValue
    return e

  events: ->
    'keyup input': 'setModelValue'
    'click button': 'act'

  setModelValue: (e) ->
    @model.set @sets, e.target.value

  setDomValue: ->
    value = @model.get @sets
    $input = @$ 'input'
    domValue = $input.val()

    if domValue isnt value
      $input.val value

  act: -> @trigger 'act', @model.get @sets

