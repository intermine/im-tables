_ = require 'underscore'
{View} = require 'backbone'

module.exports = class ModelDisplay extends View

  tagName: 'code'

  initialize: ->
    @listenTo @model, 'change', @render

  render: ->
    @$el.html _.escape JSON.stringify @model.toJSON(), null, 2

