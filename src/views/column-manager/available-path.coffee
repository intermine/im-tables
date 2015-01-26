_ = require 'underscore'
UnselectedColumn = require './unselected-column'

CUTOFF = 900

module.exports = class AvailablePath extends UnselectedColumn

  # a function that will help us find the connected list, without
  # having a reverence to the parent directly.
  parameters: ['findActives']

  restoreTitle: 'columns.AddColumnToSortOrder'

  events: -> _.extend super,
    mousedown: 'onMouseDown'
    dragstart: 'onDragStart'
    dragstop: 'onDragStop'

  onMouseDown: ->
    @fixAppendTo()

  # Cannot be set correctly on init., since when this element is rendered
  # it is likely part of a document fragment, and thus its appendTo
  # will not be available.
  fixAppendTo: ->
    @$el.draggable 'option', 'appendTo', @$el.closest('.well')
    modalWidth = @$el.closest('.modal').width()
    wide = (modalWidth >= CUTOFF)
    @$el.draggable 'option', 'axis', (if wide then null else 'y')

  onDragStart: ->
    @state.set dragged: @model.get 'path'
    @$el.addClass 'ui-dragging'

  onDragStop: ->
    @state.unset 'dragged'
    @$el.removeClass 'ui-dragging'

  postRender: ->
    # copied out of bootstrap variables - if only they could be shared!
    # TODO - move to common file.
    modalWidth = @$el.closest('.modal').width()
    wide = (modalWidth >= CUTOFF)
    index = @model.collection.indexOf @model
    @$el.draggable
      axis: (if wide then null else 'y')
      connectToSortable: @findActives()
      helper: 'clone'
      revert: 'invalid'
      opacity: 0.8
      cancel: 'i,a,button'
      zIndex: 1000

    @$('[title]').tooltip placement: (if index is 0 then 'bottom' else 'top')
