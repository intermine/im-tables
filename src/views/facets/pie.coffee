FrequencyVisualisation = require './frequency-visualisation'

module.exports = class PieFacet extends FrequencyVisualisation

    className: 'im-grouped-facet im-pie-facet im-facet'

    getChartPalette = ->
      {PieColors} = intermine.options
      if _.isFunction PieColors
        paint = PieColors
      else
        paint = d3.scale[PieColors]()

      (d, i) -> paint i

    _drawD3Chart: ->
      h = @chartHeight
      w = @$el.closest(':visible').width()
      r = h * 0.4
      ir = h * 0.1
      donut = d3.layout.pie().value (d) -> d.get 'count'

      colour = getChartPalette()

      chart = d3.select(@chartElem).append('svg')
                .attr('class', 'chart')
                .attr('height', h)
                .attr('width', w)

      arc = d3.svg.arc()
              .startAngle( (d) -> d.startAngle )
              .endAngle( (d) -> d.endAngle )
              .innerRadius((d) -> if d.data.get('selected') then ir + 5 else ir)
              .outerRadius((d) -> if d.data.get('selected') then r + 5 else r)

      arc_group = chart.append('svg:g')
                       .attr('class', 'arc')
                       .attr('transform', "translate(#{ w / 2},#{h / 2})")
      centre_group = chart.append('svg:g')
                          .attr('class', 'center_group')
                          .attr('transform', "translate(#{ w / 2},#{h / 2})")
      label_group = chart.append("svg:g")
                         .attr("class", "label_group")
                         .attr("transform", "translate(#{w/2},#{h/2})")

      whiteCircle = centre_group.append("svg:circle")
                                .attr("fill", "white")
                                .attr("r", ir)

      getTween = (d, i) ->
        j = d3.interpolate({startAngle: 0, endAngle: 0}, d)
        (t) -> arc j t
      
      paths = arc_group.selectAll('path').data(donut @items.models)
      paths.enter().append('svg:path')
          .attr('class', 'donut-arc')
          .attr('stroke', 'white')
          .attr('stroke-width', 0.5)
          .attr('fill', colour)
          .on('click', (d, i) -> d.data.set selected: not d.data.get 'selected')
          .on('mouseover', (d, i) -> d.data.trigger 'hover')
          .on('mouseout', (d, i) -> d.data.trigger 'unhover')
          .transition()
            .duration(intermine.options.D3.Transition.Duration)
            .attrTween('d', getTween)

      total = @items.reduce ((sum, m) -> sum + m.get 'count'), 0
      percent = (d) -> (d.data.get('count') / total * 100).toFixed(1)

      paths.each (d, i) ->
        title = "#{ d.data.get 'item' }: #{ percent d }%"
        placement = if (d.endAngle + d.startAngle) / 2 > Math.PI then 'left' else 'right'
        $(@).tooltip {title, placement, container: @chartElem}
      paths.transition()
        .duration(intermine.options.D3.Transition.Duration)
        .ease(intermine.options.D3.Transition.Easing)
        .attrTween("d", getTween)

      @items.on 'change:selected', =>
        paths.data(donut @items.models).attr('d', arc)
        paths.transition()
          .duration(intermine.options.D3.Transition.Duration)
          .ease(intermine.options.D3.Transition.Easing)

      this



