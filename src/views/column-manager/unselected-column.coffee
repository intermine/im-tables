SelectedColumn = require './selected-column'

Templates = require '../../templates'

module.exports = class UnselectedColumn extends SelectedColumn

  template: Templates.template 'column-manager-unselected-column'

  events: ->
    'click .im-restore-view': 'removeView' # Same logic as remove - remove from collection.


