scope 'intermine.snippets.facets', {
    OnlyOne: _.template """
            <div class="alert alert-info im-all-same">
                All <%= count %> values are the same: <strong><%= item %></strong>
            </div>
        """
}

# Hack to fix tooltip positioning for SVG.
# This should continue to work with future versions,
# as it basically just makes the positioning alogrithm
# compatible with SVG. I know this is fixed in bootstrap 2.3.0+,
# but there is no programmatic version of bootstrap available.
oldPos = $.fn.tooltip.Constructor.prototype.getPosition
$.fn.tooltip.Constructor.prototype.getPosition = ->
  ret = oldPos.apply(@, arguments)
  el = @$element[0]
  if (not ret.width and not ret.height and 'http://www.w3.org/2000/svg' is el.namespaceURI)
    {width, height} = (el.getBoundingClientRect?() ? el.getBBox())
    return $.extend ret, {width, height}
  else
    return ret

do ->

    ##----------------
    ## Returns a fn to calculate a point Z(x), 
    ## the Probability Density Function, on any normal curve. 
    ## This is the height of the point ON the normal curve.
    ## For values on the Standard Normal Curve, call with Mean = 0, StdDev = 1.
    NormalCurve = (mean, stdev) ->
        (x) ->
            a = x - mean
            Math.exp(-(a * a) / (2 * stdev * stdev)) / (Math.sqrt(2 * Math.PI) * stdev)

    Int = (x) -> parseInt(x, 10)

    MORE_FACETS_HTML = """
        <i class="icon-plus-sign pull-right" title="Showing top ten. Click to see all values"></i>
    """
    FACET_TITLE = _.template """
        <dt><i class="icon-chevron-right"></i><%= title %></dt>
    """
    FACET_TEMPLATE = _.template """
        <dd>
            <a href=#>
                <b class="im-facet-count pull-right">
                    (<%= count %>)
                </b>
                <%= item %>
            </a>
        </dd>
    """

    class ColumnSummary extends Backbone.View
        tagName: 'div'
        className: "im-column-summary"
        initialize: (facet, @query) ->
            if _(facet).isString()
                @facet =
                    path: facet
                    title: facet.replace(/^[^\.]+\./, "").replace(/\./g, " > ")
                    ignoreTitle: true
            else
                @facet = facet


        render: =>
            attrType = @query.getPathInfo(@facet.path).getType()
            clazz = if attrType in intermine.Model.NUMERIC_TYPES
              NumericFacet
            else
              FrequencyFacet
            initialLimit = 400 # items
            fac = new clazz(@query, @facet, initialLimit, @noTitle)
            @$el.append fac.el
            fac.render()
            this

    class FacetView extends Backbone.View
        tagName: "dl"
        initialize: (@query, @facet, @limit, @noTitle) ->
            @query.on "change:constraints", @render
            @query.on "filter:summary", @render

        render: =>
            unless @noTitle
                @$dt = $(FACET_TITLE @facet).appendTo @el
                @$dt.click =>
                    @$dt.siblings().slideToggle()
                    @$dt.find('i').first().toggleClass 'icon-chevron-right icon-chevron-down'
            this

    class FrequencyFacet extends FacetView
        render: (filterTerm = "") ->
            return if @rendering
            @rendering = true
            @$el.empty()
            super()
            $progress = $ """
                <div class="progress progress-info progress-striped active">
                    <div class="bar" style="width:100%"></div>
                </div>
            """
            $progress.appendTo @el
            getSummary = @query.filterSummary @facet.path, filterTerm, @limit
            getSummary.fail @remove
            getSummary.done (results, stats, count) =>
              @query.trigger 'got:summary:total', @facet.path, stats.uniqueValues, results.length, count
              $progress.remove()
              @$dt?.append " (#{stats.uniqueValues})"
              hasMore = if results.length < @limit then false else (stats.uniqueValues > @limit)
              if hasMore
                more = $(MORE_FACETS_HTML).appendTo(@$dt).tooltip( placement: 'left' ).click (e) =>
                  e.stopPropagation()
                  e.preventDefault()
                  got = @$('dd').length()
                  areVisible = @$('dd').first().is ':visible'
                  @query.summarise @facet.path, (items) =>
                    @addItem(item).toggle(areVisible) for item in items[got..]
                    more.tooltip('hide').remove()
              
              summaryView = if stats.uniqueValues <= 1
                @$el.empty()
                if stats.uniqueValues then (intermine.snippets.facets.OnlyOne results[0]) else "No results"
              else
                Vizualization = @getVizualization(stats)
                new Vizualization(@query, @facet, results, hasMore, filterTerm)

              # The facets need appending before rendering so that they calculate their
              # dimensions correctly.
              @$el.append if summaryView.el then summaryView.el else summaryView
              summaryView.render?()

              @rendering = false
        
        getVizualization: (stats) ->
          unless @query.canHaveMultipleValues @facet.path
            if @query.getType(@facet.path) in intermine.Model.BOOLEAN_TYPES
              return BooleanFacet
            else if stats.uniqueValues <= intermine.options.MAX_PIE_SLICES
              return PieFacet
          return HistoFacet

        addItem: (item) =>
            $dd = $(FACET_TEMPLATE(item)).appendTo @el
            $dd.click =>
                @query.addConstraint
                    title: @facet.title
                    path: @facet.path
                    op: "="
                    value: item.item
            $dd

    class NumericRange extends Backbone.Model

      _defaults: {}

      setLimits: (limits) ->
        @_defaults = limits

      get: (prop) ->
        ret = null
        if @has(prop)
          ret = super(prop)
        else if prop of @_defaults
          ret = @_defaults[prop]
        ret

      set: (name, value) ->
        if _.isString(name) and (name of @_defaults)
          meth = if name is 'min' then 'max' else 'min'
          super(name, Math[meth](@_defaults[name], value))
        else
          super(arguments...)

      isNotAll: ->
        {min, max} = @toJSON()
        (min? and min isnt @_defaults.min) or (max? and max isnt @_defaults.max)

    class NumericFacet extends FacetView

        events:
            'click': (e) -> e.stopPropagation()
            'keyup input.im-range-val': 'incRangeVal'

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
            @range = new NumericRange()
            @range.on 'change', =>
                if @shouldDrawBox()
                    x = @xForVal(@range.get('min'))
                    width = @xForVal(@range.get('max')) - x
                    @drawSelection(x, width)
                else
                    @selection?.remove()
                    @selection = null
            @container = @make "div"
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
            promise.fail @remove
            this

        handleSummary: (items, total) =>
            @throbber.remove()
            summary = items[0]
            @w = @$el.closest(':visible').width() * 0.95
            if summary.item?
                if items.length > 1
                    # A numerical column configured to present as a string column.
                    hasMore = if items.length < @limit then false else (total > @limit)
                    @paper.remove()
                    hf = new HistoFacet @query, @facet, items, hasMore, ""
                    @$el.append hf.el
                    return hf.render()
                else
                    # Dealing with the single value edge case here...
                    return @$el.empty().append intermine.snippets.facets.OnlyOne(summary)
            @mean = parseFloat(summary.average)
            @dev = parseFloat(summary.stdev)
            @range.setLimits(summary)
            @max = summary.max
            @min = summary.min
            @step = step = if @query.getType(@facet.path) in ["int", "Integer"] then 1 else 0.1
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
                <table class="table table-bordered table-condensed">
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

        incRangeVal: (e) ->
          $input = $(e.target)
          prop = $input.data 'var'
          current = now = (@range.get(prop) ? @[prop])
          switch e.keyCode
            when 40 then now--
            when 38 then now++

          @range.set(prop, now) unless now is current

        drawSlider: =>
            $(@container).append """
                <div class="btn-group pull-right">
                  <button class="btn btn-primary disabled">Apply</button>
                  <button class="btn btn-cancel disabled">Reset</button>
                </div>
                <label>Range:</label>
                <input type="text" data-var="min" class="im-range-min input im-range-val" value="#{@min}">
                <span>...</span>
                <input type="text" data-var="max" class="im-range-max input im-range-val" value="#{@max}">
                <div class="slider"></div>
              """
            for prop, idx of {min: 0, max: 1} then do (prop, idx) =>
                @range.on "change:#{prop}", (m, val) =>
                    val = @round(val)
                    @$("input.im-range-#{prop}").val "#{ val }"
                    if $slider.slider('values', idx) isnt val
                        $slider.slider('values', idx, val)
            @range.on 'change', () =>
                changed = @range.has('min') and @range.has('max') and (@range.get('min') > @min or @range.get('max') < @max)
                @$('.btn').toggleClass "disabled", !changed
                for prop, idx of {min: 0, max: 1}
                    unless @range.has(prop)
                        $slider.slider('values', idx, @[prop])
                        @$("input.im-range-#{prop}").val "#{ @[prop] }"
            $slider = @$('.slider').slider
                range: true
                min: @min
                max: @max
                values: [@min, @max]
                step: @step
                slide: (e, ui) => @range.set min: ui.values[0], max: ui.values[1]
            @query.on 'range:selected', (from, upto) =>
                from = Math.min(from, @range.get('min')) if @range.has('min')
                upto = Math.max(upto, @range.get('max')) if @range.has('min')
                @range.set min: @round(from), max: @round(upto)
            @$('.btn-cancel').click => @range.clear()
            @$('.btn-primary').click =>
                @query.constraints = _(@query.constraints).filter (c) =>
                    c.path != @facet.path
                @query.addConstraints [
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

        drawChart: (items) =>
          if d3?
            @_drawD3Chart(items)
          else if Raphael?
            @_drawRaphaelChart(items)
          # Boo-hoo, can't draw a pretty chart.

        _drawD3Chart: (items) ->
          bottomMargin = 18
          rightMargin = 14
          n = items[0].buckets + 1
          console.log items
          h = @chartHeight
          most = d3.max items, (d) -> d.count
          x = d3.scale.linear().domain([1, n]).range([@leftMargin, @w - rightMargin])
          y = d3.scale.linear().domain([0, most]).rangeRound([0, h - bottomMargin])
          # Replace our hack with a d3 scale.
          @xForVal = d3.scale.linear().domain([@min, @max]).range([@leftMargin, @w - rightMargin])
          xToVal = d3.scale.linear().domain([1, n]).range([@min, @max])
          val = (x) => @round xToVal x
          @paper = chart = d3.select(@canvas).append('svg')
            .attr('class', 'chart')
            .attr('width', @w)
            .attr('height', h)

          chart.selectAll('rect')
            .data(items)
            .enter().append('rect')
              .attr('x', (d, i) -> x(d.bucket) - 0.5)
              .attr('y', h - bottomMargin)
              .attr('width', (d) -> x(d.bucket + 1) - x(d.bucket))
              .attr('height', 0)
              .on('click', (d, i) => @range.set min: val(d.bucket), max: val(d.bucket + 1))
              .each (d, i) ->
                title = "#{ val d.bucket } >= x < #{ val (d.bucket + 1)}: #{ d.count } items"
                $(@).tooltip {title}

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
            .enter().append('svg:line')
              .attr('x1', x).attr('x2', x)
              .attr('y1', h - (bottomMargin * 0.75)).attr('y2', h - bottomMargin)
              .attr('stroke', 'gray')
              .attr('text-anchor', 'start')

          this

        _drawRaphaelChart: (items) ->
            @paper = Raphael(@canvas, @$el.width(), @chartHeight)
            h = @chartHeight
            hh = h * 0.7
            max = _.max _.pluck items, "count"
            
            acceptableGap = Math.max (@w / 15), "#{items[0].max}".split("").length * 5 * 1.5
            p = @paper
            gap = 0
            topMargin = h * 0.1
            baseLine = hh + topMargin

            for tick in [0 .. 10] then do (tick) =>
                line = p.path "M#{@leftMargin - 4},#{baseLine - (hh / 10 * tick)} h#{@w - gap}"
                line.node.setAttribute "class", "tickline"

            yaxis = @paper.path "M#{@leftMargin - 4}, #{baseLine} v-#{hh}"
            yaxis.node.setAttribute "class", "yaxis"

            for tick in [0, 5, 10] then do (tick) =>
                ypos = baseLine - (hh / 10 * tick)
                val = max / 10 * tick
                t = @paper.text(leftMargin - 6, ypos, val.toFixed()).attr
                    "text-anchor": "end"
                    "font-size": "10px"
                # Lord knows why?? Firefox does not need this... not needed in absolute...
                if $.browser.webkit
                    t.translate 0, -ypos unless @$el.offsetParent().filter( -> $(@).css("position") is "absolute").length

            for item, i in items then do (item, i) =>
                prop = item.count / max
                pathCmd = "M#{(item.bucket - 1) * stepWidth + @leftMargin},#{baseLine} v-#{hh * prop} h#{stepWidth - gap} v#{hh * prop} z"
                path = @paper.path pathCmd

            item = items[0]
            fixity = if item.max - item.min > 5 then 0 else 2
            lastX = 0
            for xtick in [0 .. item.buckets]
                curX = xtick * stepWidth + @leftMargin
                if lastX is 0 or curX - lastX >= acceptableGap or xtick is item.buckets
                    lastX = curX
                    val = item.min + (xtick * ((item.max - item.min) / item.buckets))
                    @paper.text(curX, baseLine + 5, val.toFixed(fixity))

            this

        drawSelection: (x, width) =>
          @selection?.remove()
          if (x <= 0) and (width >= @w)
            return # Nothing to do.

          if d3?
            @selection = @paper.append('svg:rect')
              .attr('x', x)
              .attr('y', 0)
              .attr('width', width)
              .attr('height', @chartHeight)
              .attr('class', 'rubberband-selection')
          else if Raphael?
            @selection = @paper.rect(x, 0, width, @chartHeight)
            @selection.node.setAttribute 'class', 'rubberband-selection'
          else
            console.error("Cannot draw selection without SVG lib")

        _selecting_paths_: false

        drawCurve: () =>
            if @max is @min
                $(@el).remove()
                return
            sections = ((@max - @min) / @dev).toFixed()
            w = @$el.width()
            h = @chartHeight
            nc = NormalCurve(w / 2, w / sections)
            factor = h / nc(w / 2)
            invert = (x) -> h - x + 2
            scale = (x) -> x * factor
            f = _.compose invert, scale, nc
            xs = [1 .. w]
            points = _.zip xs, (f(x) for x in xs)
            pathCmd = "M1,#{ h }S#{ points.join(",") }L#{w - 1},#{ h }Z"

            # Draw the curve
            @paper.path(pathCmd)
            for stdevs in [0 .. ((sections/2) + 1)]
                xs = _.uniq([w / 2 - (stdevs * w / sections), w / 2 + (stdevs * w / sections)])

                getPathCmd = (x) -> "M#{x},#{h}L#{x},#{f(x)}"
                drawDivider = (x) => @paper.path(getPathCmd(x))
                drawDivider x for x in xs when ( 0 <= x <= w )


    class PieFacet extends Backbone.View
        className: 'im-grouped-facet im-pie-facet im-facet'

        chartHeight: 100

        initialize: (@query, @facet, items, @hasMore, @filterTerm) ->
            @items = new Backbone.Collection(items)
            @items.each (item) -> item.set "visibility", true

            @items.maxCount = @items.first()?.get "count"
            @items.on "change:selected", =>
                someAreSelected = @items.any((item) -> item.get "selected")
                allAreSelected = !@items.any (item) -> not item.get "selected"
                @$('.im-filter .btn').attr "disabled", !someAreSelected
                @$('.im-filter .btn-toggle-selection').attr("disabled", allAreSelected)
                                                    .toggleClass("im-invert", someAreSelected)

        events:
            'click .im-filter .btn-primary': 'addConstraint'
            'click .im-filter .btn-cancel': 'resetOptions'
            'click .im-filter .btn-toggle-selection': 'toggleSelection'
            click: (e) ->
                e.stopPropagation()
                e.preventDefault()

        resetOptions: (e) ->
            @items.each (item) -> item.set "selected", false

        toggleSelection: (e) ->
            @items.each (item) -> item.set("selected", !item.get "selected") if item.get "visibility"

        addConstraint: (e) ->
            newCon = path: @facet.path
            vals = (item.get "item" for item in @items.filter (item) -> item.get "selected")
            if vals.length is 1
                if vals[0] is null
                    newCon.op = 'IS NULL'
                else
                    newCon.op = '='
                    newCon.value = "#{vals[0]}"
            else
                newCon.op = "ONE OF"
                newCon.values = vals
            newCon.title = @facet.title unless @facet.ignoreTitle
            @query.addConstraint newCon

        render: -> @addChart().addControls()

        @GREEKS = "αβγδεζηθικλμνξορστυφχψω".split("")

        addChart: ->
          if d3?
            @_drawD3Chart()
          else if Raphael?
            @_drawRaphaelChart()
          # Boo-hoo, can't draw a pretty chart.

        _drawD3Chart: ->
          h = @chartHeight
          w = @$el.closest(':visible').width()
          r = h * 0.4
          ir = h * 0.1
          donut = d3.layout.pie().value (d) -> d.get 'count'
          paint = d3.scale.category20()
          colour = (d, i) ->
            paint i

          elem = @make "div"
          @$el.append elem
          chart = d3.select(elem).append('svg')
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
            $(@).tooltip {title, placement}
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

        @_drawRaphaelChart: ->
            return this if @items.all (i) -> i.get("count") is 1
            h = @chartHeight
            w = @$el.closest(':visible').width()
            r = h * 0.8 / 2
            chart = @make "div"
            @$el.append chart
            @paper = Raphael chart, w, h
            cx = w / 2
            cy = h / 2

            total = @items.reduce ((a, b) -> a + b.get "count"), 0
            degs = 0
            i = 0
            texts = @items.map (item) =>
                prop = item.get("count") / total
                item.set "percent", prop * 100
                rads = 2 * Math.PI * prop
                arc = if prop > 0.5 then 1 else 0
                dy = r + (-r * Math.cos rads)
                dx = r * Math.sin rads
                cmd = "M#{cx},#{cy} v-#{r} a#{r},#{r} 0 #{arc},1 #{dx},#{dy} z"
                path = @paper.path cmd
                item.set "path", path
                path.click () -> item.set selected: not item.get('selected')
                path.hover (() -> item.trigger 'hover'), (() -> item.trigger 'unhover')
                path.rotate degs, cx, cy
                textRads = (Raphael.rad degs) + (rads / 2)
                textdy = -(r * 0.6 * Math.cos textRads)
                textdx = r * 0.6 * Math.sin textRads
                item.set "symbol", PieFacet.GREEKS[i++]
                t = @paper.text cx, cy, item.get "symbol" #item.get "item"
                t.attr
                    "font-size": "14px"
                    "text-anchor": if textdx > 0 then "start" else "end"
                t.translate textdx, textdy
                # Lord knows why?? - not needed if in absolute...
                if $.browser.webkit
                    t.translate 0, -(r * 1.5) unless @$el.offsetParent().filter( -> $(@).css("position") is "absolute").length
                t.node.setAttribute "class", "pie-label"
                degs += 360 * prop
                t

            t.toFront() for t in texts
            this

        filterControls: """
          <div class="input-prepend">
              <span class="add-on"><i class="icon-refresh"></i></span><input type="text" class="input-medium search-query filter-values" placeholder="Filter values">
          </div>
        """

        addControls: ->
            $grp = $("""
            <form class="form form-horizontal">
                #{ @filterControls }
                <div class="im-item-table">
                    <table class="table table-condensed">
                        <colgroup>
                            #{ @colClasses.map( (cl) -> "<col class=#{cl}>").join('') }
                        </colgroup>
                        <thead>
                            <tr>#{ @columnHeaders.map( (h) -> "<th>#{ h }</th>" ).join('') }</tr>
                        </thead>
                        <tbody class="scrollable"></tbody>
                    </table>
                </div>
            </form>""").appendTo @el
            $grp.button()
            @items.each (item) =>
                r = @makeRow item
                $grp.find('tbody').append r
            $grp.append """
                <div class="im-filter btn-group">
                  #{ @buttons }
                </div>
            """

            @initFilter()

            this

        buttons: """
          <button type="submit" class="btn btn-primary" disabled>Filter</button>
          <button class="btn btn-cancel" disabled>Reset</button>
          <button class="btn btn-toggle-selection"></button>
        """

        initFilter: ->
            xs = @items
            $valFilter = @$ '.filter-values'
            if @filterTerm
                $valFilter.val @filterTerm
            facet = @
            $valFilter.keyup (e) ->
                if facet.hasMore or (facet.filterTerm and $(@).val().length < facet.filterTerm.length)
                    _.delay (() -> facet.query.trigger('filter:summary', $valFilter.val())), 750
                else
                    pattern = new RegExp $(@).val(), "i"
                    xs.each (x) -> x.set "visibility", pattern.test x.get("item")
            $valFilter.prev().click (e) ->
                $(@).next().val(facet.filterTerm)
                xs.each (x) -> x.set "visibility", true

        colClasses: ["im-item-selector", "im-item-value", "im-item-count"]

        columnHeaders: [' ', 'Item', 'Count']

        makeRow: (item) ->
            row = new FacetRow(item, @items)
            row.render().$el
            

    class FacetRow extends Backbone.View

        tagName: "tr"
        className: "im-facet-row"

        isBelow: () ->
            parent = @$el.closest '.im-item-table'
            @$el.offset().top + @$el.outerHeight() > parent.offset().top + parent.outerHeight()

        isAbove: () ->
            parent = @$el.closest '.im-item-table'
            @$el.offset().top < parent.offset().top

        isVisible: () -> not (@isAbove() or @isBelow())

        initialize: (@item, @items) ->
            @item.on "change:selected", =>
                isSelected = @item.get "selected"
                if @item.has "path"
                    item.get("path").node.setAttribute "class", if isSelected then "selected" else ""
                @$el.toggleClass "active", isSelected
                if isSelected isnt @$('input').attr("checked")
                    @$('input').attr "checked", isSelected

            @item.on 'hover', =>
                @$el.addClass 'hover'
                unless @isVisible()
                    above = @isAbove()
                    surrogate = $ """
                        <div class="im-facet-surrogate #{ if above then 'above' else 'below'}">
                            <i class="icon-caret-#{ if above then 'up' else 'down' }"></i>
                            #{ @item.get('item') }: #{ @item.get('count') }
                        </div>
                    """
                    itemTable = @$el.closest('.im-item-table').append surrogate
                    newTop = if above
                        itemTable.offset().top + itemTable.scrollTop()
                    else
                        itemTable.scrollTop() + itemTable.offset().top + itemTable.outerHeight() - surrogate.outerHeight()
                    surrogate.offset top: newTop

            @item.on 'unhover', =>
                @$el.removeClass 'hover'
                s = @$el.closest('.im-item-table').find('.im-facet-surrogate').fadeOut 'fast', () ->
                    s.remove()

            @item.on "change:visibility", => @$el.toggle @item.get "visibility"

        events:
            'click': 'handleClick'
            'change input': 'handleChange'

        render: ->
            percent = (parseInt(@item.get("count")) / @items.maxCount * 100).toFixed(1)
            @$el.append """
                <td class="im-selector-col">
                    <span>#{ ((@item.get "symbol") || "") }</span>
                    <input type="checkbox">
                </td>
                <td class="im-item-col">
                  #{@item.get("item") ? '<span class=null-value>NO VALUE</span>' }
                </td>
                <td class="im-count-col">
                    <div class="im-facet-bar" style="width:#{percent}%">
                        #{@item.get "count"}
                    </div>
                </td>
            """
            if @item.get "percent"
                @$el.append """<td class="im-prop-col"><i>#{@item.get("percent").toFixed()}%</i></td>"""

            this

        handleClick: (e) ->
            e.stopPropagation()
            if e.target.type isnt 'checkbox'
                @$('input').trigger "click"

        handleChange: (e) ->
            e.stopPropagation()
            @item.set "selected", @$('input').is ':checked'

    class HistoFacet extends PieFacet

        className: 'im-grouped-facet im-facet'

        chartHeight: 50
        leftMargin: 25

        colClasses: ["im-item-selector", "im-item-value", "im-item-count"]

        columnHeaders: [' ', 'Item', 'Count']
        
        addChart: ->
          if d3?
            @_drawD3Chart()
          else if Raphael?
            @_drawRaphaelChart()
          # Boo-hoo, can't draw a pretty chart.

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
          chart = @make "div"
          @$el.append chart
          chart = d3.select(chart).append('svg')
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
            .each (d, i) -> $(@).tooltip title: "#{ d.get 'item' }: #{ d.get 'count' }"

          chart.append('line')
            .attr('x1', 0)
            .attr('x2', w)
            .attr('y1', h - .5)
            .attr('y2', h - .5)
            .style('stroke', '#000')
          
          @items.on 'change:selected', =>
            chart.selectAll('rect').data(@items.models).transition()
              .duration(intermine.options.D3.Transition.Duration)
              .ease(intermine.options.D3.Transition.Easing)
              .attr('class', (d) -> rectClass + (if d.get('selected') then '-selected' else ''))

          this


        _drawRaphaelChart: ->
            h = @chartHeight
            hh = h * 0.8
            w = @$el.closest(':visible').width() * 0.95
            f = @items.first()
            max = f.get "count"
            return this if @items.all (i) -> i.get("count") is 1
            chart = @make "div"
            @$el.append chart
            p = @paper = Raphael chart, w, h
            gap = w * 0.01
            topMargin = h * 0.1
            leftMargin = 30
            stepWidth = (w - (leftMargin + 1)) / @items.size()
            baseline = hh + topMargin

            for tick in [0 .. 10] then do (tick) ->
                line = p.path "M#{leftMargin - 4},#{baseline -  (hh / 10 *  tick)} h#{w - gap}"
                line.node.setAttribute "class", "tickline"

            yaxis = @paper.path "M#{leftMargin - 4},#{baseline} v-#{hh}"
            yaxis.node.setAttribute "class", "yaxis"
            for tick in [0 .. 10] then do (tick) =>
                ypos = baseline - (hh / 10 * tick)
                val = max / 10 * tick
                unless val % 1
                    t = @paper.text(leftMargin - 6, ypos, val.toFixed()).attr
                        "text-anchor": "end"
                        "font-size": "10px"
                    # Lord knows why?? Firefox does not need this... not needed in absolute...
                    if $.browser.webkit
                        t.translate 0, -ypos unless @$el.offsetParent().filter( -> $(@).css("position") is "absolute").length


            @items.each (item, i) =>
                prop = item.get("count") / max
                pathCmd = "M#{i * stepWidth + leftMargin},#{baseline} v-#{hh * prop} h#{stepWidth - gap} v#{hh * prop} z"
                path = @paper.path pathCmd
                path.click () -> item.set selected: not item.get('selected')
                path.hover (() -> item.trigger 'hover'), (() -> item.trigger 'unhover')

                item.set "path", path

            this


    class BooleanFacet extends PieFacet

      initialize: ->
        super(arguments...)
        if @items.length is 2
          @items.on 'change:selected', (quello, selected) =>
            @items.each (questo) -> questo.set(selected: false) if (selected and questo isnt quello)

      filterControls: ''

      initFilter: ->

      buttons: """
        <button type="submit" class="btn btn-primary" disabled>Filter</button>
        <button class="btn btn-cancel" disabled>Reset</button>
      """

    scope "intermine.results", {
        ColumnSummary,
        FacetView,
        FrequencyFacet,
        NumericFacet,
        PieFacet,
        FacetRow,
        HistoFacet,
        BooleanFacet
    }
