_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

require '../../messages/columns'

module.exports = class ColumnMangerButton extends CoreView

  tagName: 'button'

  className: 'btn btn-default column-manager-button'

  template: Templates.template 'column-manager-button'

  parameters: ['query']

