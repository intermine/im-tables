CoreView = require '../../core-view'
Templates = require '../../templates'

# A component that manages a single tag.
module.exports = class ListTag extends CoreView

  className: 'im-list-tag label label-primary'

  template: Templates.template 'list-tag'

  events: ->
    'click .im-remove': 'removeAndDestroy'

  # Once rendered, activate the tooltip.
  postRender: ->
    @activateTooltip()

  # If it has a title - then tooltip it.
  activateTooltip: -> @$('[title]').tooltip()

  # Destroy the tag, remove it from the model, and this view of it from the DOM
  removeAndDestroy: ->
    @model.collection.remove @model
    @model.destroy()
    @$el.fadeOut 400, => @remove()

