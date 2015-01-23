_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

module.exports = class SortOrderEditor extends CoreView

  className: 'im-sort-order-editor'

  template: Templates.template 'column-manager-sort-order-editor'

  getData: -> _.extend super, hasRubbish: false
