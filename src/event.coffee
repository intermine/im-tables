# Simple event that can be passed to handlers for cancellable events.
module.exports = class Event

  constructor: (@data, @target) ->

  cancel: -> @cancelled = true

  preventDefault: -> @cancel()

  stopPropagation: -> # no-op
