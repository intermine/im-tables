d3 = require 'd3-browserify'
_ = require 'underscore'

CoreView = require '../../core-view'

module.exports = class VisualisationBase extends CoreView

  chartHeight: 100
  chartWidth: 0 # the width we have available - set during render.

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

  # These methods need implementing by sub-classes - standard ABC stuff here.
  getScales: -> throw new Error 'Not implemented'

  selectNodes: (chart) -> throw new Error 'not implemented'

  getChartData: (scales) -> throw new Error 'not implemented'

  exit: (selection) -> selection.remove()

  enter: (selection, scales) -> throw new Error 'not implemented'

  update: (selection, scales) -> throw new Error 'not implemented'

  # If you want axes, then implement this method.
  drawAxes: (chart, scales) -> # optional.

  # Return true to abort drawing the chart.
  shouldNotDrawChart: -> false

  _drawD3Chart: ->
    return if @shouldNotDrawChart()
    @initChart()
    scales = @getScales()
    chart = @getCanvas()

    @updateChart chart, scales

    @drawAxes chart, scales

  # Call this method when the data changes to update the visualisation.
  updateChart: (chart, scales) ->
    return if @shouldNotDrawChart()
    chart ?= @getCanvas() # when updating
    scales ?= @getScales() # when updating

    # Bind each data item to a node in the chart.
    selection = @selectNodes(chart).data(@getChartData(scales))

    # Remove any unneeded nodes
    @exit selection.exit()

    # Initialise any new nodes
    @enter selection.enter(), scales

    # Transition the nodes to their new state.
    @update selection, scales

  # Set properties that we need access to the DOM to calculate.
  initChart: ->
    @chartWidth = @$el.closest(':visible').width()

  # Get the canvas if it exists, or create it.
  getCanvas: ->
    @paper ?= d3.select(@el)
                .append('svg')
                  .attr('class', 'im-summary-chart')
                  .attr('width', @chartWidth)
                  .attr('height', @chartHeight)
