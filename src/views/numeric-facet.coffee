_ = require 'underscore'
$ = require 'jquery'

options = require '../options'

NumericRange = require '../models/numeric-range'
OnlyOne = require '../templates/only-one'
{FacetView} = require './facet-view'
HistoFacet = require './facets/histogram'

numeric = (x) -> +x

class exports.NumericFacet extends FacetView

  initialize: ->
    super arguments...
    @range = new NumericRange()
    @range.on 'change', =>
        if @shouldDrawBox()
          if @range.nulled
            @drawSelection 0, 25
          else
            x = @xForVal(@range.get('min'))
            width = @xForVal(@range.get('max')) - x
            @drawSelection(x, width)
        else
            @selection?.remove()
            @selection = null

    @range.on 'change', =>
      if @range.isNotAll()
        @drawEstCount()
      else
        @estCount?.remove()
        @estCount = null

    @range.on 'reset', =>
      {min, max} = @range.toJSON()
      @$slider?.slider 'option', 'values', [min, max]
      for prop, val of {min, max}
        @$("input.im-range-#{prop}").val "#{ val }"

    for prop, idx of {min: 0, max: 1} then do (prop, idx) =>
      @range.on "change:#{prop}", (m, val) =>
        if m.nulled
          @$("input.im-range-#{prop}").val "null"

        return unless val?
        val = @round(val)
        @$("input.im-range-#{prop}").val "#{ val }"
        if @$slider?.slider('values', idx) isnt val
            @$slider?.slider('values', idx, val)

    @range.on 'change', () =>
      changed = @range.isNotAll() #@range.get('min') > @min or @range.get('max') < @max
      @$('.btn').toggleClass "disabled", !changed

  events: ->
    _.extend (super arguments...), {
      'click': (e) -> e.stopPropagation()
      'keyup input.im-range-val': 'incRangeVal'
      'change input.im-range-val': 'setRangeVal'
      'click .btn-primary': 'changeConstraints'
      'click .btn-cancel': 'clearRange'
    }

  clearRange: -> @range?.clear(); @range?.trigger 'reset'

  changeConstraints: (e) ->
    e.preventDefault()
    e.stopPropagation()
    fpath = @facet.path.toString()
    @query.constraints = _(@query.constraints).filter (c) -> c.path isnt fpath
    if @range.nulled
      newConstraints = [{
        path: @facet.path
        op: 'IS NULL'
      }]
    else
      newConstraints = [
          {
              path: @facet.path
              op: ">="
              value: @range.get('min')
          },
          {
              path: @facet.path
              op: "<="
              value: @range.get('max')
          }
      ]

    @query.addConstraints newConstraints

  className: "im-numeric-facet"

  chartHeight: 70
  leftMargin: 25

  xForVal: (val) =>
      if val is @min
          return @leftMargin
      if val is @max
          return @w
      conversionRate = (@w - @leftMargin) / (@max - @min)
      return @leftMargin + (conversionRate * (val - @min))

  valForX: (x) =>
      if x <= @leftMargin
          return @min
      if x >= @w
          return @max
      conversionRate = (@max - @min) / (@w - @leftMargin)
      return @min + (conversionRate * (x - @leftMargin))

  shouldDrawBox: -> @range.isNotAll()

  render: ->
      super()
      @container = @make "div",
          class: "facet-content im-facet"
      @$el.append(@container)
      @canvas = @make "div"
      $(@canvas).mouseout => @_selecting_paths_ = false
      $(@container).append @canvas
      @throbber = $ """
        <div class="progress progress-info progress-striped active">
          <div class="bar" style="width:100%"></div>
        </div>
      """
      @throbber.appendTo @el
      promise = @query.summarise @facet.path, @handleSummary
      promise.then (=> @trigger 'ready', @), @remove
      this

  remove: ->
    @$slider?.slider 'destroy'
    delete @$slider
    @range?.off()
    delete @range
    super()

  inty = (type) -> type in ["int", "Integer", "long", "Long"]

  handleSummary: (items, stats) =>
      @throbber.remove()
      summary = items[0]
      @w = @$el.closest(':visible').width() * 0.95
      if summary.item?
          if items.length > 1
              # A numerical column configured to present as a string column.
              hasMore = if items.length < @limit then false else (stats.uniqueValues > @limit)
              hf = new HistoFacet @query, @facet, items, hasMore, ""
              @$el.append hf.el
              return hf.render()
          else
              # Dealing with the single value edge case here...
              return @$el.empty().append OnlyOne(summary)
      @mean = parseFloat(summary.average)
      @dev = parseFloat(summary.stdev)
      @range.setLimits(summary)
      @max = summary.max
      @min = summary.min
      @step = step = if inty(@query.getType @facet.path) then 1 else Math.abs((@max - @min) / 100)
      @round = (x) -> if step is 1 then Math.round(x) else x
      if summary.count?
        @stepWidth = (@w - (@leftMargin + 1)) / items[0].buckets
        @drawChart(items)
      else
        @drawCurve()
      @drawStats()
      @drawSlider()

  drawStats: () =>
      $(@container).append """
          <table class="table table-condensed">
              <thead>
                  <tr>
                      <th>Min</th>
                      <th>Max</th>
                      <th>Mean</th>
                      <th>Standard Deviation</th>
                  </tr>
              </thead>
              <tbody>
                  <tr>
                      <td>#{ @min }</td>
                      <td>#{ @max }</td>
                      <td>#{ @mean.toFixed(5) }</td>
                      <td>#{ @dev.toFixed(5) }</td>
                  </tr>
              </tbody>
          </table>
      """

  setRangeVal: (e) ->
    $input = $(e.target)
    prop = $input.data 'var'

    current = (@range.get(prop) ? @[prop])
    next = numeric $input.val()
    if _.isNan next
      return $input.val current
    @range.set(prop, next) unless current is next

  incRangeVal: (e) ->
    $input = $(e.target)
    prop = $input.data 'var'
    current = next = (@range.get(prop) ? @[prop])
    switch e.keyCode
      when 40 then next -= @step
      when 38 then next += @step

    @range.set(prop, next) unless next is current

  drawSlider: =>
      $(@container).append """
          <div class="btn-group pull-right">
            <button class="btn btn-primary disabled">Apply</button>
            <button class="btn btn-cancel disabled">Reset</button>
          </div>
          <input type="text" data-var="min" class="im-range-min input im-range-val" value="#{@min}">
          <span>...</span>
          <input type="text" data-var="max" class="im-range-max input im-range-val" value="#{@max}">
          <div class="slider"></div>
        """

      opts =
        range: true
        min: @min
        max: @max
        values: [@min, @max]
        step: @step
        slide: (e, ui) => @range?.set min: ui.values[0], max: ui.values[1]

      @$slider = @$('.slider').slider opts

  drawChart: (items) =>
    if d3?
      setTimeout (=> @_drawD3Chart(items)), 0
    # Boo-hoo, can't draw a pretty chart.

  _drawD3Chart: (items) ->
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
        .each (d, i) ->
          title = getTitle d
          $(@).tooltip {title, container}

    rects = chart.selectAll('rect').data(items)
      .transition()
      .duration(options.D3.Transition.Duration)
      .ease(options.D3.Transition.Easing)
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
      .enter().append('svg:line')
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

  _selecting_paths_: false
