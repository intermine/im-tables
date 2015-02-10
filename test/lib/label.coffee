_ = require 'underscore'
CoreView = require 'imtables/core-view'

module.exports = class Label extends CoreView

  className: 'container'

  parameters: ['attr', 'getter']

  getData: ->
    attr: @attr
    value: @getter(@model)

  modelEvents: -> change: @reRender

  template: _.template """
    <div class="row">
      <div class="col-md-3">
        <label><%- attr %></label>
      </div>
      <div class="col-md-9">
        <span class="label label-primary"><%- value %></span>
      </div>
    </div>
  """

