_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

OrderElement = require './order-element'

activeId = (model) -> "active_#{ model.get 'id' }"
inactiveId = (model) -> "inactive_#{ model.get 'id' }"

module.exports = class SortOrderEditor extends CoreView

  className: 'im-sort-order-editor'

  template: Templates.template 'column-manager-sort-order-editor'

  getData: -> _.extend super, hasRubbish: false

  postRender: ->
    oes = @$ '.im-active-oes'
    @collection.each (model) =>
      @renderChild (activeId model), (new OrderElement {model}), oes
