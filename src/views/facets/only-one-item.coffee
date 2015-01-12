CoreView = require '../../core-view'
Templates = require '../../templates'

# What we display when we display only one thing.
module.exports = class OnlyOneItem extends CoreView

  className: 'im-only-one'

  template: Templates.template 'only_one_item'
