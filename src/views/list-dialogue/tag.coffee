CoreView = require '../../core-view'
Templates = require '../../templates'

# A component that manages a single tag.
module.exports = class ListTag extends CoreView

  className: 'label label-primary'

  template: Templates.template 'list-tag'

  events: ->
    'click .im-remove': 'removeAndDestroy'

  removeAndDestroy: ->
    @model.destroy()
    @remove()

