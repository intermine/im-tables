_ = require 'underscore'

CoreView = require '../../core-view'

module.exports = class VisualisationBase extends CoreView

  chartHeight: 100

  # This method needs implementing by sub-classes - standard ABC stuff here.
  _drawD3Chart: -> throw new Error 'Not Implemented'

  initialize: ->
    super
    @listenTo @model, 'change:loading', @reRender

  postRender: ->
    return if @model.get 'loading'
    @addChart()

  addChart: -> _.defer =>
    try
      @_drawD3Chart()
    catch e
      @model.set error: e

