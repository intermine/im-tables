_ = require 'underscore'
{View} = require 'backbone'

module.exports = class ModelDisplay extends View

  tagName: 'code'

  initialize: ->
    @listenTo @model, 'change', @render
    @listenTo @model, 'change:error', @logError

  logError: -> if e = @model.get 'error'
    console.error(e, e.stack)

  render: ->
    data = @model.toJSON()
    if data.error?.message
      data.error = data.error.message
    @$el.html _.escape JSON.stringify data, null, 2

