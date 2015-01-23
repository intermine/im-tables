_ = require 'underscore'

SelectedColumn = require './selected-column'
Templates = require '../../templates'

TEMPLATE_PARTS = [
  'column-manager-order-direction',
  'column-manager-path-name',
  'column-manager-path-remover'
]

nextDirection = (dir) -> if (dir is 'ASC') then 'DESC' else 'ASC'

module.exports = class OrderElement extends SelectedColumn

  removeTitle: 'columns.RemoveOrderElement'

  template: Templates.templateFromParts TEMPLATE_PARTS

  modelEvents: -> _.extend super,
    'change:direction': @reRender

  events: -> # Same logic as remove - remove from collection.
    'click .im-restore-view': 'removeView'
    'click .im-change-direction': 'changeDirection'

  changeDirection: ->
    @model.swap 'direction', nextDirection

