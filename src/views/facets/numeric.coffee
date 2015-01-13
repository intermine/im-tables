d3 = require 'd3'

VisualisationBase = require './visualisation-base'

NULL_SELECTION_WIDTH = 25

# TODO - draw chart still needs work.
module.exports = class NumericDistribution extends VisualisationBase

  className: "im-numeric-distribution"

  leftMargin: 25
  bottomMargin: 18
  rightMargin: 14
  chartHeight: 70

  w: 0 # the width we have available.

  # Range is shared by other components, so we accept it from the outside.
  initialize: ({@range}) ->
    super
    @listenTo @range, 'change reset', @onChangeRange

  # The rubber-band selection.
  selection: null

  # An estimated count of the number in the selection.
  estCount: null

  onChangeRange: ->
    if @shouldDrawBox()
      if @range.nulled
        @drawSelection 0, NULL_SELECTION_WIDTH
      else
        x = @xForVal(@range.get('min'))
        width = @xForVal(@range.get('max')) - x
        @drawSelection(x, width)
      @drawEstCount()
    else
      @selection?.remove()
      @selection = null
      @estCount?.remove()
      @estCount = null

  # Caculate the x position for a particular domain value.
  # this a place
  xForVal: (val) -> throw new Error('not rendered yet')

  # Calculate the domain value for a particular graphical x position.
  valForX: (x) =>
    {min, max} = @model.pick 'min', 'max'
    if x <= @leftMargin
      return min
    if x >= @w
      return max
    conversionRate = (max - min) / (@w - @leftMargin)
    return min + (conversionRate * (x - @leftMargin))

  # We should draw the selection box when there is a selection.
  shouldDrawBox: -> @range.isNotAll()

  # Flag so we know if we are selecting paths.
  __selecting_paths: false

  isIntish: -> @model.get('type') in ['int', 'Integer', 'long', 'Long']

  events: ->
    'mouseout': => @__selecting_paths = false # stop selecting when the mouse leaves the el.

  initChart: ->
    @w = @$el.closest(':visible').width()
    @stepWidth = (@w - (@leftMargin + 1)) / items[0].buckets
    @round = if @isIntish() then Math.round else _.identity

  # the histogram is a list of values, eg: [1, 3, 5, 0, 10, 7, 4]
  # these represent a set of equal width buckets across the range
  # of the available values.
  _drawD3Chart: ->
    @initChart()
    {min, max} = @model.pick 'min', 'max'
    histogram = @model.getHistogram()
    n = histogram.length + 1 # buckets are 1-indexed
    h = @chartHeight
    most = d3.max histogram
    counts = [0, most]
    values = [min, max]
    buckets = [1, n]
    xPositions = [@leftMargin, @w - @rightMargin]

    # The scales
    # The chart compares buckets to counts
    @x = x = d3.scale.linear()
                .domain(buckets)
                .range(xPositions)
    @y = y = d3.scale.linear()
                .domain(counts)
                .rangeRound([0, h - @bottomMargin])

    @xForVal = d3.scale.linear()
                 .domain(values)
                 .range(xPositions)

    @valueForBucket = bucketToVal = d3.scale.linear()
                                .domain(buckets)
                                .range(values)

    @valForX = xToVal = d3.scale.linear()
                                .domain(xPositions)
                                .range(values)


    val = (x) => @round xToVal x

    # Named wrong? surely this is xval?
    bucketVal = (x) ->
      raw = val x
      if raw < min
        min
      else if raw > max
        max
      else
        raw

    bucketRange = (bucket) ->
      if bucket?
        [min, max] = (bucketVal(bucket + delta) for delta in [0, 1])
      else
        [min, max] = [0 - bucketVal(2), bucketVal(1)]
      {min, max}

    getTitle = (count, i) ->
      bucket = i + 1
      title = if item.bucket?
        brange = bucketRange item.bucket
        "#{ brange.min } >= x < #{ brange.max }: #{ item.count } items"
      else
        "x is null: #{ item.count } items"

    @paper = chart = d3.select(@canvas).append('svg')
                        .attr('class', 'chart')
                        .attr('width', @w)
                        .attr('height', h)

    container = @canvas

    barClickHandler = (d, i) =>
      if d.bucket?
        @range?.set bucketRange d.bucket
      else
        @range?.nullify()

    for item in items when item.bucket?
      item.brange = bucketRange item.bucket

    chart.selectAll('rect')
          .data(items)
          .enter().append('rect')
            .attr('x', (d, i) -> x(d.bucket) - 0.5)
            .attr('y', h - bottomMargin)
            .attr('width', (d) -> Math.abs(x(d.bucket + 1) - x(d.bucket)))
            .attr('height', 0)
            .classed('im-null-bucket', (d) -> d.bucket is null)
            .on('click', barClickHandler)
            .each (d, i) -> $(@).tooltip {container, title: getTitle d, i}

    rects = chart.selectAll('rect').data(items)
                  .transition()
                  .duration(intermine.options.D3.Transition.Duration)
                  .ease(intermine.options.D3.Transition.Easing)
                  .attr('y', (d) -> h - bottomMargin - y(d.count) - 0.5)
                  .attr('height', (d) -> y d.count)

    chart.append('line')
          .attr('x1', 0)
          .attr('x2', @w)
          .attr('y1', h - bottomMargin - .5)
          .attr('y2', h - bottomMargin - .5)
          .style('stroke', '#000')

    axis = chart.append('svg:g')

    axis.selectAll('line').data(x.ticks(n))
        .enter()
          .append('svg:line')
          .attr('x1', x).attr('x2', x)
          .attr('y1', h - (bottomMargin * 0.75)).attr('y2', h - bottomMargin)
          .attr('stroke', 'gray')
          .attr('text-anchor', 'start')

    this

  drawEstCount: ->
    @estCount?.remove()
    return false unless d3?
    @estCount = @paper.append('text')
                      .classed('im-est-count', true)
                      .attr('x', @w * 0.75)
                      .attr('y', 22)
                      .text("~#{ @estimateCount() }")

  sumCounts = (xs) -> _.reduce(xs, ((total, x) -> total + x.count), 0)

  fracWithinRange = (range, min, max) ->
    return 0 unless range
    rangeSize = range.max - range.min
    overlap = if range.min < min
      Math.min(range.max, max) - min
    else
      max - Math.max(range.min, min)
    overlap / rangeSize

  getPartialCount = (min, max) -> (item) ->
    if item?
      item.count * fracWithinRange item.brange, min, max
    else
      0

  estimateCount: ->
    if @range.nulled
      sumCounts @items.filter (i) -> i.bucket is null
    else
      {min, max} = @range.toJSON()
      fullBuckets = sumCounts @items.filter (i) -> i.brange? and i.brange.min >= min and i.brange.max <= max
      [partialLeft] = @items.filter (i) -> i.brange? and i.brange.min < min and i.brange.max > min
      [partialRight] = @items.filter (i) -> i.brange? and i.brange.max > max and i.brange.min < max
      [left, right] = [partialLeft, partialRight].map getPartialCount min, max
      @round fullBuckets + left + right

  drawSelection: (x, width) =>
    @selection?.remove()
    if (x <= 0) and (width >= @w)
      return # Nothing to do.

    @selection = @paper.append('svg:rect')
      .attr('x', x)
      .attr('y', 0)
      .attr('width', width)
      .attr('height', @chartHeight * 0.9)
      .classed('rubberband-selection', true)
