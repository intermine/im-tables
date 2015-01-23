_ = require 'underscore'
UnselectedColumn = require './unselected-column'

module.exports = class AvailablePath extends UnselectedColumn

  events: -> _.extend super,
    mousedown: 'fixAppendTo'
    dragstart: 'onDragStart'
    dragstop: 'onDragStop'

  # Cannot be set correctly on init., since when this element is rendered
  # it is likely part of a document fragment, and thus its appendTo
  # will not be available.
  fixAppendTo: ->
    @$el.draggable 'option', 'appendTo', @$el.closest('.well')

  onDragStart: -> @$el.addClass 'ui-dragging'
  onDragStop: -> @$el.removeClass 'ui-dragging'

  postRender: ->
    @$el.draggable
      axis: 'y'
      helper: 'clone'
      revert: 'invalid'
      opacity: 0.8
      cancel: 'i,a,button'
      zIndex: 1000
