d3 = require 'd3'

VisualisationBase = require './visualisation-base'

# TODO - draw chart still needs work.
module.exports = class NumericDistribution extends VisualisationBase

  className: "im-numeric-distribution"

  chartHeight: 70
  leftMargin: 25

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
        @drawSelection 0, 25
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
  xForVal: (val) =>
    {min, max} = @model.pick 'min', 'max'
    if val is min
      return @leftMargin
    if val is max
      return @w
    conversionRate = (@w - @leftMargin) / (max - min)
    return @leftMargin + (conversionRate * (val - min))

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

  events: ->
    'mouseout': => @__selecting_paths = false # stop selecting when the mouse leaves the el.

  _drawD3Chart: (items) ->
    @stepWidth = (@w - (@leftMargin + 1)) / items[0].buckets
    @items = items
    bottomMargin = 18
    rightMargin = 14
    n = items[0].buckets + 1
    h = @chartHeight
    most = d3.max items, (d) -> d.count
    x = d3.scale.linear().domain([1, n]).range([@leftMargin, @w - rightMargin])
    y = d3.scale.linear().domain([0, most]).rangeRound([0, h - bottomMargin])
    @xForVal = d3.scale.linear()
                  .domain([@min, @max])
                  .range([@leftMargin, @w - rightMargin])

    xToVal = d3.scale.linear().domain([1, n]).range([@min, @max])
    val = (x) => @round xToVal x
    bucketVal = (x) =>
      raw = val x
      if raw < @min
        @min
      else if raw > @max
        @max
      else
        raw
    bucketRange = (bucket) ->
      if bucket?
        [min, max] = (bucketVal(bucket + delta) for delta in [0, 1])
      else
        [min, max] = [0 - bucketVal(2), bucketVal(1)]
      {min, max}

    getTitle = (item) ->
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
            .each (d, i) -> $(@).tooltip {container, title: getTitle d}

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

    if d3?
      @selection = @paper.append('svg:rect')
        .attr('x', x)
        .attr('y', 0)
        .attr('width', width)
        .attr('height', @chartHeight * 0.9)
        .classed('rubberband-selection', true)
    else
      console.error("Cannot draw selection without SVG lib")
