class HistoFacet extends FrequencyVisualisation

  className: 'im-grouped-facet im-facet'

  chartHeight: 50
  leftMargin: 25
  
  _drawD3Chart: ->
    return this if @items.all (i) -> 1 is i.get 'count'
    data = @items.models
    w = @$el.closest(':visible').width() * 0.95
    n = data.length
    itemW = (w - @leftMargin) / data.length
    h = @chartHeight
    f = @items.first()
    max = f.get "count"
    x = d3.scale.linear().domain([0, n]).range([@leftMargin, w])
    y = d3.scale.linear().domain([0, max]).rangeRound([0, h])

    chart = d3.select(@chartElem).append('svg')
              .attr('class', 'chart')
              .attr('width', w)
              .attr('height', h)

    rectClass = if n > w / 4 then 'squashed' else 'bar'
    rects = chart.selectAll('rect')
    rects.data(data)
          .enter().append('rect')
            .attr('class', rectClass)
            .attr('width', itemW)
            .attr('y', h) # Correct value set in transition
            .attr('height', 0) # Correct value set in transition
            .attr('x', (d, i) -> x(i) - 0.5)
            .on('click', (d, i) -> d.set selected: not d.get 'selected')
            .on('mouseover', (d, i) -> d.trigger 'hover')
            .on('mouseout', (d, i) -> d.trigger 'unhover')

    # Animate their entry
    chart.selectAll('rect').data(@items.models).transition()
          .duration(intermine.options.D3.Transition.Duration)
          .ease(intermine.options.D3.Transition.Easing)
          .attr('y', (d) -> h - y(d.get 'count') - 0.5)
          .attr('height', (d) -> y d.get 'count')

    chart.append('line')
      .attr('x1', 0)
      .attr('x2', w)
      .attr('y1', h - .5)
      .attr('y2', h - .5)
      .style('stroke', '#000')

    onSelection = =>
      _.defer =>
        chart.selectAll('rect')
          .data(@items.models)
          .transition()
          .duration(intermine.options.D3.Transition.Duration)
          .ease(intermine.options.D3.Transition.Easing)
          .attr('class', (d) ->
            rectClass + (if d.get('selected') then '-selected' else ''))
    
    @items.on 'change:selected', _.throttle onSelection, 150
    this

