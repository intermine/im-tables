d3 = require 'd3-browserify'
$ = require 'jquery'
_ = require 'underscore'

Options = require '../../options'
Messages = require '../../messages'
require '../../messages/summary' # include the summary messages.
VisualisationBase = require './visualisation-base'

NULL_SELECTION_WIDTH = 25

# A function that takes the number of a bucket and a function that will turn that into
# a value in the continous range of values for the paths and produces an object saying
# what the range of values are for the bucket.
# (Function<int, Number>, int) -> {min :: Number, max :: Number}
bucketRange = (bucketVal, bucket) ->
  [min, max] = (bucketVal(bucket + delta) for delta in [0, 1])
  {min, max}

# get a filter to find buckets fully contained in a given range.
fullyContained = (min, max) -> (d) -> d.range.min >= min and d.range.max <= max
# get a filter to find buckets partially overlapping a range to its left or right
partiallyOverlapping = (min, max) -> (d) ->
  (d.range.min < min and d.range.max > min) or (d.range.max > max and d.range.min < max)

# Function that enforces limits on a value.
limited = (min, max) -> (x) ->
  if x < min
    min
  else if x > max
    max
  else
    x

# Sum up the .count properties of the things in an array.
sumCounts = (xs) -> _.reduce xs, ((total, x) -> total + x.count), 0

# Sum up a list of partially overlapping buckets.
sumPartials = (min, max, partials) ->
  fn = (sum, bucket) -> sum + (getPartialCount min, max, bucket)
  _.reduce partials, fn, 0

# Get the amount of of a given range a particular span overlaps.
# eg: ({min: 0, max: 10}, 0, 10) -> 1
# eg: ({min: 0, max: 10}, 20, 21) -> 0
# eg: ({min: 0, max: 10}, 0, 7) -> 0.7
# eg: ({min: 0, max: 10}, 5, 7) -> 0.2
fracWithinRange = (range, min, max) ->
  return 0 unless range
  rangeSize = range.max - range.min
  overlap = if range.min < min
    Math.min(range.max, max) - min
  else
    max - Math.max(range.min, min)
  overlap / rangeSize

# Given a particular span, and a bucket, return an estimate of the number
# of values within the span, assuming that the bucket is evenly populated
# based on the size of the bucket and the amount of overlap.
getPartialCount = (min, max, {count, range}) -> count * fracWithinRange range, min, max

# Helper that constructs a scale fn from the given input domain to the given output range
scale = (input, output) -> d3.scale.linear().domain(input).range(output)

# TODO - draw chart still needs work.
module.exports = class NumericDistribution extends VisualisationBase

  className: "im-numeric-distribution"

  # Dimensions of the chart.
  leftMargin: 25
  bottomMargin: 18
  rightMargin: 14
  chartHeight: 70
  chartWidth: 0 # the width we have available - set during render.

  # Flag so we know if we are selecting paths.
  __selecting_paths: false

  # The rubber-band selection.
  selection: null

  # An estimated count of the number in the selection.
  estCount: null

  # Range is shared by other components, so we accept it from the outside.
  # We listen to changes on the range and respond by drawing a selection box.
  initialize: ({@range}) ->
    super
    @listenTo @range, 'change reset', @onChangeRange

  # Things to check when we are initialised.
  invariants: ->
    hasRange: "No range"
    hasHistogramModel: "Wrong model: #{ @model }"

  hasRange: -> @range?

  hasHistogramModel: -> @model?.getHistogram?

  # The rendering logic. This component renders a numeric histogram.
  # 
  # the histogram is a list of values, eg: [1, 3, 5, 0, 10, 7, 4],
  # these represent a set of equal width buckets across the range
  # of the available values. Buckets are 1-indexed (in the example
  # above there are 7 buckets, labelled 1-7). The number of buckets
  # is available on the SummaryItems model as 'buckets', the
  # histogram can be accessed with SummaryItems::getHistogram.

  # Each bucket is represented by a rect which is placed on the canvas. Axes
  # are drawn with tick-lines.
  _drawD3Chart: ->
    @initChart()
    scales = @getScales()
    chart = @getCanvas()

    # Bind each histogram bucket to a rectangle in the chart.
    rects = chart.selectAll('rect').data @getChartData scales

    # Remove any unneeded rectangles
    rects.exit().remove()

    # Initialise any new rectangles.
    @enter rects.enter(), scales

    # Make sure the rectangles have the correct height.
    @update rects, scales

    @drawAxes scales

  # For convenience we store the bucket number with the count, although it
  # is trivial to calculate from the index. The range is also stored, which
  # is more of a faff to calculate (since you need access to the scales)
  getChartData: (scales) ->
    scales ?= @getScales()
    for c, i in @model.getHistogram()
      {count: c, bucket: (i + 1), range: (bucketRange scales.bucketToVal, i + 1)}

  # Set properties that we need access to the DOM to calculate.
  initChart: ->
    @chartWidth = @$el.closest(':visible').width()
    @bucketWidth = (@model.get('max') - @model.get('min')) / @model.get('buckets')
    @stepWidth = (@chartWidth - (@leftMargin + 1)) / @model.get('buckets')

  # There are five separate things here:
  #  - x positions (the graphical position horizontally)
  #  - y positions (the graphical position vertically)
  #  - values (the values the path can hold - a continous range)
  #  - buckets (the number of the equal width buckets a value falls into)
  #  - counts (the number of values in a bucket)
  # The x scale is BucketNumber -> XPos
  # The y scale is Count -> YPos
  # We also need reverse scales for finding value for an x-position.
  getScales: ->
    {min, max} = @model.pick 'min', 'max'
    n = @model.get 'buckets'
    histogram = @model.getHistogram()
    most = d3.max histogram
    round = @getRounder()

    # These are the five separate things.
    counts = [0, most]
    values = [min, max]
    buckets = [1, n + 1]
    xPositions = [@leftMargin, @chartWidth - @rightMargin]
    yPositions = [0, @chartHeight - @bottomMargin]

    # wrapper around a ->val scale that applies the appropriate rounding and limits
    toVal = (inputs) -> _.compose (limited min, max), round, (scale inputs, values)

    scales = # return:
      x: (scale buckets, xPositions) # A scale from bucket -> x
      y: (scale counts, yPositions)  # A scale from count -> y
      valToX: (scale values, xPositions) # A scale from value -> x
      xToVal: (toVal xPositions) # A scale from x -> value
      bucketToVal: (toVal buckets) # A scale from bucket -> min val

  # Does the path represent a whole number value, such as an integer?
  isIntish: -> @model.get('type') in ['int', 'Integer', 'long', 'Long', 'short', 'Short']

  # Return a function we can use to round values we calculate from x positions.
  getRounder: -> if @isIntish() then Math.round else _.identity

  # Get the canvas if it exists, or create it.
  getCanvas: ->
    @paper ?= d3.select(@el)
                .append('svg')
                  .attr('class', 'im-summary-chart')
                  .attr('width', @chartWidth)
                  .attr('height', @chartHeight)

  # The things we do to new rectangles.
  enter: (selection, scales) ->
    # For performance it is best to pass this in, but this line makes it clear what scales
    # refers to.
    scales ?= @getScales()
    container = @el
    h = @chartHeight

    # When the user clicks on a bar, set the selected range to the range
    # the bar covers.
    barClickHandler = (d, i) =>
      if d.count > 0
        @range.set bucketRange scales.bucketToVal, d.bucket
      else
        @range.nullify()

    # Get the tooltip text for the bar.
    getTitle = ({bucket, count}) ->
      range = bucketRange scales.bucketToVal, bucket
      Messages.getText 'summary.Bucket', {range, count}

    # The inital state of the bars is 0-height in the correct x position, with click
    # handlers and tooltips attached.
    selection.append('rect')
             .attr 'x', (d, i) -> scales.x d.bucket # - 0.5 # subtract half a bucket to be at start
             .attr 'width', (d) -> (scales.x d.bucket + 1) - (scales.x d.bucket)
             .attr 'y', h - @bottomMargin # set the height to 0 initially.
             .attr 'height', 0
             .classed 'im-bucket', true
             .classed 'im-null-bucket', (d) -> d.bucket is null # I suspect this is pointless.
             .on 'click', barClickHandler
             .each (d) -> $(@).tooltip {container, title: getTitle d}

  update: (selection, scales) ->
    scales ?= @getScales()
    h = @chartHeight
    bm = @bottomMargin
    {Duration, Easing} = Options.get('D3.Transition')
    height = (d) -> scales.y d.count
    selection.transition()
             .duration Duration
             .ease Easing
             .attr 'height', height
             .attr 'y', (d) -> h - bm - (height d) - 0.5

  drawAxes: (scales) ->
    scales ?= @getScales()
    chart = @getCanvas()

    # Draw a line across the bottom of the chart.
    chart.append('line')
         .attr 'x1', 0
         .attr 'x2', @chartWidth
         .attr 'y1', @chartHeight - @bottomMargin - .5
         .attr 'y2', @chartHeight - @bottomMargin - .5
         .style 'stroke', '#000'

    axis = chart.append('svg:g')

    ticks = scales.x.ticks @model.get('buckets')

    # Draw a tick line for each bucket.
    axis.selectAll('line').data(ticks)
        .enter()
          .append('svg:line')
          .attr('x1', scales.x)
          .attr('x2', scales.x)
          .attr('y1', @chartHeight - (@bottomMargin * 0.75))
          .attr('y2', @chartHeight - @bottomMargin)
          .attr('stroke', 'gray')
          .attr('text-anchor', 'start')

  # Events, with their definitions and handlers.
  # Also, each bar has a handler (see ::enter) and the range itself
  # has handlers (see ::initialize)
  events: ->
    'mouseout': => @__selecting_paths = false # stop selecting when the mouse leaves the el.

  # Draw a label saying how many things we thing are contained within the current selection.
  drawEstCount: ->
    # Create it if it doesn't exist.
    @estCount ?= @getCanvas().append('text')
                             .classed('im-est-count', true)
                             .attr('x', @chartWidth * 0.75)
                             .attr('y', @chartHeight * 0.25)
    # Set it to display the current estimated count.
    @estCount.text("~#{ @estimateCount() }")

  # Estimate how many values are likely to be contained in the given selected range.
  estimateCount: ->
    if @range.nulled
      0
    else
      {min, max} = @range.toJSON()
      histogram = @getChartData()
      fullBuckets = histogram.filter fullyContained min, max
      partials = histogram.filter partiallyOverlapping min, max
      Math.round (sumCounts fullBuckets) + (sumPartials min, max, partials)

  # Draw the rubber-band selection over the top of the canvas. The selection
  # is a full height box starting at x and extending to the right for width pixels.
  drawSelection: (x, width) ->
    if (not x?) or (x <= 0) or (width >= @chartWidth)
      return @removeSelection()
      
    # Create it if it doesn't exist.
    @selection ?= @getCanvas().append('svg:rect')
                              .attr('y', 0)
                              .attr('height', @chartHeight * 0.9)
                              .classed('rubberband-selection', true)
    # Change its width and x position.
    @selection.attr('x', x).attr('width', width)

  # When the range changes, draw the selection box, if we need to.
  onChangeRange: ->
    if @shouldDrawBox()
      scales = @getScales()
      {min, max} = @range.toJSON()
      start = scales.valToX min
      width = (scales.valToX max) - start
      @drawSelection(start, width)
      @drawEstCount()
    else
      @removeSelection()
      @removeEstCount()

  removeEstCount: ->
    @estCount?.remove()
    @estCount = null

  removeSelection: ->
    @selection?.remove()
    @selection = null

  # We should draw the selection box when there is a selection.
  shouldDrawBox: -> @range.isNotAll()

  remove: -> # remove the chart if necessary.
    @removeSelection()
    @removeEstCount()
    @paper?.remove()
    super

