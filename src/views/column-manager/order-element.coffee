SelectedColumn = require './selected-column'
Templates = require '../../templates'

module.exports = class OrderElement extends SelectedColumn

  template: Templates.templateFromParts ['column-manager-path-name']

  events: -> # Same logic as remove - remove from collection.
    'click .im-restore-view': 'removeView'

