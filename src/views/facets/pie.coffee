_ = require 'underscore'
$ = require 'jquery'
d3 = require 'd3-browserify'

Options = require '../../options'

VisualisationBase = require './visualisation-base'

KEY = (d) -> d.data.get 'id'

DONUT = d3.layout.pie().value (d) -> d.get 'count'

TWEEN_START =
  startAngle: 0
  endAngle: 0

getChartPalette = ->
  colors = Options.get 'PieColors'
  paint = if _.isFunction colors
    colors
  else
    d3.scale[colors]()

  (d) -> paint d.data.get('id')

getStartPosition = (model) -> model.get('currentPieCoords') ? TWEEN_START

opacity = (d) -> if d.data.get('visible') then 1 else 0.25

getEndPosition = (startAngle, endAngle, model) ->
  startAngle: startAngle
  endAngle: endAngle
  selected: (if model.get 'selected' then 1 else 0)

# close over the arc function.
getArcTween = (arc) -> ({startAngle, endAngle, data}) ->
  # Interpolate from start position to current position.
  model = data
  start = getStartPosition model
  end = getEndPosition startAngle, endAngle, model
  getDatumAtTime = d3.interpolateObject start, end # A dataspace interpolator
  model.set currentPieCoords: getDatumAtTime 1 # save the final result for next time.
  (t) -> arc getDatumAtTime t # The arc for each point in time.

# Predicate that determines if the mid-point of a segment is past six-o'clock in position.
isPastSixOClock = (d) -> (d.endAngle + d.startAngle) / 2 > Math.PI

# Get an arc function that reads objects with three properties:
#  - innerRadius
#  - outerRadius
#  - selected :: float between 0 - 1
getArc = (outerRadius, innerRadius, selectionBump) ->
  d3.svg.arc()
        .startAngle (d) -> d.startAngle
        .endAngle (d) -> d.endAngle
        .innerRadius (d) -> innerRadius + (d.selected * selectionBump)
        .outerRadius (d) -> outerRadius + (d.selected * selectionBump)

module.exports = class PieChart extends VisualisationBase

  chartWidth: 120
  chartHeight: 120

  className: 'im-pie-chart'

  initialize: ->
    super
    @listenTo @model.items, 'change:selected change:visible', @update
    @listenTo Options, 'change:PieColors', @onChangePalette
    @onChangePalette()

  onChangePalette: ->
    @colour = getChartPalette()
    @update()

  _drawD3Chart: ->
    h = @chartHeight
    w = @$el.closest(':visible').width()
    outerRadius = h * 0.4
    innerRadius = h * 0.1
    selectionBump = h * 0.08

    chart = d3.select(@el).append('svg')
              .attr('class', 'chart')
              .attr('height', h)
              .attr('width', w)

    @arc = getArc outerRadius, innerRadius, selectionBump

    @arc_group = chart.append('svg:g')
                      .attr('class', 'arc')
                      .attr('transform', "translate(#{ w / 2},#{h / 2})")

    centre_group = chart.append('svg:g')
                        .attr('class', 'center_group')
                        .attr('transform', "translate(#{ w / 2},#{h / 2})")

    label_group = chart.append("svg:g")
                        .attr("class", "label_group")
                        .attr("transform", "translate(#{w / 2},#{h / 2})")

    whiteCircle = centre_group.append("svg:circle")
                              .attr("fill", "white")
                              .attr("r", innerRadius)

    @update()

  # For each item, add a wedge with the correct classes and a tooltip.
  enter: (selection) ->
    container = @el
    total = @model.items.reduce ((sum, m) -> sum + m.get 'count'), 0
    percent = (d) -> (d.data.get('count') / total * 100).toFixed(1)
    activateTooltip = (d) ->
      $el = $ @ # functions are called in the context of the SVG node.
      title = "#{ d.data.get 'item' }: #{ percent d }%"
      placement = if (isPastSixOClock d) then 'left' else 'right'
      $el.tooltip {title, placement, container}
    selection.append('svg:path')
             .attr 'class', 'donut-arc'
             .on 'click', (d) -> d.data.toggle 'selected'
             .on 'mouseover', (d) -> d.data.mousein()
             .on 'mouseout', (d) -> d.data.mouseout()
             .each activateTooltip

  # If a wedge has gone away, remove it.
  exit: (selection) -> selection.remove()

  getChartData: -> @model.items.models.slice()

  # all update does is push selected elements out a bit - there is no enter/exit
  # going on. At least, there shouldn't be. 
  update: ->
    return unless @arc_group?
    paths = @arc_group.selectAll('path').data (DONUT @getChartData()), KEY

    @exit paths.exit()
    @enter paths.enter()

    {DurationShort, Easing} = Options.get 'D3.Transition'

    paths.attr('fill', @colour)
    paths.transition()
      .duration DurationShort
      .ease Easing
      .style 'opacity', opacity
      .attrTween 'd', (getArcTween @arc)

