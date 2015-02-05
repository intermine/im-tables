Backbone = require 'backbone'

module.exports = class PopoverFactory extends Backbone.Events

  constructor: (@service, @Preview, @popovers = {}) ->

  # IMObject -> jQuery
  get: (obj) ->
    {Preview, popovers, service} = @
    type = obj.get 'class'
    id = obj.get 'id'

    return popovers[id] if popovers[id]?

    popover = new Preview
      service: service
      model: {type, id}

    content = popover.$el

    @listenTo popover, 'rendered', -> popover.reposition()
    popover.render()

    popovers[id] = content # cache and return

  destroy: ->
    @stopListening()
    @popovers = {}

