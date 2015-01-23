SelectedColumn = require './selected-column'

Templates = require '../../templates'

TEMPLATE_PARTS = [
  'column-manager-path-name',
  'column-manager-restore-path'
]

module.exports = class UnselectedColumn extends SelectedColumn

  template: Templates.templateFromParts TEMPLATE_PARTS

  events: -> # Same logic as remove - remove from collection.
    'click .im-restore-view': 'removeView'


