_ = require 'underscore'
d3 = require 'd3'

Options = require '../../options'

VisualisationBase = require './visualisation-base'

KEY = (model) -> model.get 'id'

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

# close over the arc function.
getTween = (arc) -> (d, i) ->
  j = d3.interpolate TWEEN_START, d
  (t) -> arc j t

getArc = (outerRadius, innerRadius) ->
  d3.svg.arc()
        .startAngle (d) -> d.startAngle
        .endAngle (d) -> d.endAngle
        .innerRadius (d) -> if d.data.get('selected') then innerRadius + 5 else innerRadius
        .outerRadius (d) -> if d.data.get('selected') then outerRadius + 5 else outerRadius

module.exports = class PieChart extends VisualisationBase

  className: 'im-pie-facet im-facet'

  initialize: ->
    @listenTo @model.items, 'change:selected', @update
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

    chart = d3.select(@el).append('svg')
              .attr('class', 'chart')
              .attr('height', h)
              .attr('width', w)

    @arc = getArc outerRadius, innerRadius

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
    selection.append('svg:path')
             .attr('class', 'donut-arc')
             .attr('stroke', 'white')
             .attr('stroke-width', 0.5)
             .on('click', (d) -> d.data.toggle 'selected')
             .on('mouseover', (d) -> d.data.set hover: true)
             .on('mouseout', (d) -> d.data.set hover: false)

    selection.each (d, i) ->
      $el = $ @
      title = "#{ d.data.get 'item' }: #{ percent d }%"
      placement = if (d.endAngle + d.startAngle) / 2 > Math.PI then 'left' else 'right'
      $el.tooltip {title, placement, container}

  # If a wedge has gone away, remove it.
  exit: (selection) -> selection.remove()

  # all update does is push selected elements out a bit - there is no enter/exit
  # going on. At least, there shouldn't be. 
  update: ->
    return unless @arc_group?
    paths = @arc_group.selectAll('path').data (DONUT @items.models), KEY

    @exit paths.exit()
    @enter paths.enter()

    paths.attr('fill', @colour)
    paths.transition()
      .duration(Options.get 'D3.Transition.Duration')
      .ease(Options.get 'D3.Transition.Easing')
      .attrTween('d', (getTween @arc))

