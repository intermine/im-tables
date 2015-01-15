d3 = require 'd3-browserify'
_ = require 'underscore'

Options = require '../../options'
Messages = require '../../messages'
VisualisationBase = require './visualisation-base'

require '../../messages/summary' # include the summary messages.

# Helper that constructs a scale fn from the given input domain to the given output range
scale = (input, output) -> d3.scale.linear().domain(input).range(output)

bool = (x) -> !!x

module.exports = class HistoFacet extends VisualisationBase

  className: 'im-summary-histogram'

  chartHeight: 50
  leftMargin: 25
  bottomMargin: 0.5
  stepWidth: 0 # The width of each bar, in pixels - set during render.

  allCountsAreOne: -> @model.get('maxCount') is 1

  initialize: ->
    super
    @listenTo @model.items, 'add remove change:selected', => @updateChart()

  # Preconditions

  invariants: ->
    'hasItems': "No items, or not the right thing: #{ @model.items }"

  hasItems: -> @model?.items?.models? # It should look like a collection.

  # Set properties that we need access to the DOM to calculate.
  initChart: ->
    super
    @stepWidth = (@chartWidth - (@leftMargin + 1)) / @model.items.size()

  shouldNotDrawChart: -> @allCountsAreOne()

  # The rendering logic. This component renders a frequency histogram.

  # This component visualises one bar for each value, in a list, arrayed
  # along the x axis, with their height set to reflect their count.
  getScales: ->
    # intentionally one off, so there is enough space for the last bar.
    indices = [0, @model.items.size()] # the indices of the bars, i .. n
    counts = [0, @model.get 'maxCount'] # The range of counts, zeroed.
    yPositions = [0, @chartHeight - @bottomMargin]
    xPositions = [@leftMargin, @chartWidth]

    x = (scale indices, xPositions)
    y = (scale counts, yPositions)

    {x, y}

  # Each item is represented by a rectangle on the chart.
  selectNodes: (chart) -> chart.selectAll 'rect'

  # One bar is drawn for each item in the result set, which is the list
  # of possible values and the number of the occurances of each one, ordered
  # from most frequent to least frequent.
  getChartData: (scales) -> @model.items.models.slice()
  
  # One bar is drawn for each item.
  enter: (selection, scales) ->
    n = @model.items.size()
    w = @chartWidth
    selection.append('rect')
             .classed 'im-item-bar', true
             .classed 'squashed', n > (w / 4)
             .attr 'width', @stepWidth
             .attr 'y', @chartHeight  # Correct value set in transition
             .attr 'height', 0        # Correct value set in transition
             .attr 'x', (_, i) -> scales.x i
             .on 'click', (model) -> model.toggle 'selected'
             .on 'mouseover', (model) -> model.set hover: true
             .on 'mouseout', (model) -> mode.set hover: false

  # Transition to the correct height and selected state.
  update: (selection, scales) ->
    {Duration, Easing} = Options.get('D3.Transition')
    h = @chartHeight
    height = (model) -> scales.y model.get 'count'
    selection.transition()
             .duration Duration
             .ease Easing
             .classed 'selected', (model) -> bool model.get 'selected'
             .attr 'height', height
             .attr 'y', (model) -> h - (height model) - @bottomMargin

  # Draw an X-axis.
  drawAxes: (chart, scales) ->
    y = @chartHeight - @bottomMargin
    chart.append('line')
      .classed 'x-axis', true
      .attr 'x1', 0
      .attr 'x2', @chartWidth
      .attr 'y1', y
      .attr 'y2', y
    
