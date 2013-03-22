scope 'intermine.snippets.facets', {
    OnlyOne: _.template """
            <div class="alert alert-info im-all-same">
                All <%= count %> values are the same: <strong><%= item %></strong>
            </div>
        """
}

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

    # One day tab will be expunged, one day...
    SUMMARY_FORMATS =
      tab: 'tsv'
      csv: 'csv'
      xml: 'xml'
      json: 'json'

    # A bit of a nothing class - should be removed and replaced
    # with a factory function. TODO.
    class ColumnSummary extends Backbone.View
        tagName: 'div'
        className: "im-column-summary"
        initialize: (@query, facet) ->
            if facet.path
              @facet = facet
            else
              @facet =
                path: (@query.getPathInfo facet)
                title: facet.toString().replace(/^[^\.]+\./, "").replace(/\./g, " > ")
                ignoreTitle: true

        render: =>
            attrType = @facet.path.getType()
            clazz = if attrType in intermine.Model.NUMERIC_TYPES
              NumericFacet
            else
              FrequencyFacet
            initialLimit = intermine.options.INITIAL_SUMMARY_ROWS
            @fac = new clazz(@query, @facet, initialLimit, @noTitle)
            @$el.append @fac.el
            @fac.render()
            this

        remove: ->
          @fac?.remove()
          super()

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
            limit = @limit
            getSummary.done (results, stats, count) =>
              @query.trigger 'got:summary:total', @facet.path, stats.uniqueValues, results.length, count
              $progress.remove()
              @$dt?.append " (#{stats.uniqueValues})"
              hasMore = if results.length < limit then false else (stats.uniqueValues > limit)
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
        ret = super(prop)
        if ret?
          ret
        else if prop of @_defaults
          @_defaults[prop]
        else
          null

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
            'click .btn-primary': 'changeConstraints'
            'click .btn-cancel': 'clearRange'

        clearRange: -> @range?.clear()

        changeConstraints: ->
          @query.constraints = _(@query.constraints).filter (c) => c.path != @facet.path.toString()
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
            @range = new NumericRange()
            @range.on 'change', =>
                if @shouldDrawBox()
                    x = @xForVal(@range.get('min'))
                    width = @xForVal(@range.get('max')) - x
                    @drawSelection(x, width)
                else
                    @selection?.remove()
                    @selection = null
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
            promise.fail @remove
            this

        remove: ->
          @range?.off()
          delete @range
          super()

        handleSummary: (items, stats) =>
            @throbber.remove()
            summary = items[0]
            @w = @$el.closest(':visible').width() * 0.95
            if summary.item?
                if items.length > 1
                    # A numerical column configured to present as a string column.
                    hasMore = if items.length < @limit then false else (stats.uniqueValues > @limit)
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
              changed = @range.get('min') > @min or @range.get('max') < @max
              @$('.btn').toggleClass "disabled", !changed
              for prop, idx in ['min', 'max']
                $slider.slider('values', idx, @[prop])
                @$("input.im-range-#{prop}").val "#{ @[prop] }"

            $slider = @$('.slider').slider
              range: true
              min: @min
              max: @max
              values: [@min, @max]
              step: @step
              slide: (e, ui) => @range?.set min: ui.values[0], max: ui.values[1]

        drawChart: (items) =>
          if d3?
            @_drawD3Chart(items)
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

          container = @canvas

          chart.selectAll('rect')
            .data(items)
            .enter().append('rect')
              .attr('x', (d, i) -> x(d.bucket) - 0.5)
              .attr('y', h - bottomMargin)
              .attr('width', (d) -> x(d.bucket + 1) - x(d.bucket))
              .attr('height', 0)
              .on('click', (d, i) => @range?.set min: val(d.bucket), max: val(d.bucket + 1))
              .each (d, i) ->
                title = "#{ val d.bucket } >= x < #{ val (d.bucket + 1)}: #{ d.count } items"
                $(@).tooltip {title, container}

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
          else
            console.error("Cannot draw selection without SVG lib")

        _selecting_paths_: false


    class PieFacet extends Backbone.View
        className: 'im-grouped-facet im-pie-facet im-facet'

        chartHeight: 100

        initialize: (@query, @facet, items, @hasMore, @filterTerm) ->
            @items = new Backbone.Collection(items)
            @items.each (item) -> item.set visibility: true, selected: false

            @items.maxCount = @items.first()?.get "count"
            @items.on "change:selected", =>
                someAreSelected = @items.any((item) -> !! item.get "selected")
                allAreSelected = !@items.any (item) -> not item.get "selected"
                @$('.im-filter .btn').attr "disabled", !someAreSelected
                @$('.im-filter .btn-toggle-selection').attr("disabled", allAreSelected)
                                                    .toggleClass("im-invert", someAreSelected)
            @items.on 'add', @addItemRow, @

        basicOps =
          single: '='
          multi: 'ONE OF'
          absent: 'IS NULL'

        negateOps = (ops) ->
          ret = {}
          ret.multi = if ops.multi is 'ONE OF' then 'NONE OF' else 'ONE OF'
          ret.single = if ops.single is '=' then '!=' else '='
          ret.absent = if ops.absent is 'IS NULL' then 'IS NOT NULL' else 'IS NULL'
          ret

        events: ->
          'click .im-filter .btn-cancel': 'resetOptions'
          'click .im-filter .btn-toggle-selection': 'toggleSelection'
          'click .im-export-summary': 'exportSummary'
          'click .im-load-more': 'loadMoreItems'
          'click .im-filter .im-filter-in': (e) => @addConstraint e, basicOps
          'click .im-filter .im-filter-out': (e) => @addConstraint e, negateOps basicOps

        loadMoreItems: ->
          return if @summarising
          loader = @$('.im-load-more')
          text = loader.text()
          loader.html """<i class="icon-refresh icon-spin"></i>"""
          @limit *= 2
          @summarising = @query.filterSummary @facet.path, @filterTerm, @limit
          @summarising.done (items, stats, fcount) =>
            @hasMore = stats.uniqueValues > @limit
            newItems = items.slice @items.length
            console.log "Adding #{ newItems.length }"
            for newItem in newItems
              @items.add _.extend newItem, {visibility: true, selected: false}
            @query.trigger 'got:summary:total', @facet.path, stats.uniqueValues, items.length, fcount
          @summarising.done =>
            loader.empty().text text
            loader.toggle @hasMore
          @summarising.always => delete @summarising

        exportSummary: (e) ->
          # The only purpose of this is to reinstate the default click behaviour which is
          # being swallowed by another click handler. This is really dumb, but for future
          # reference this is how you gazump someone else's click handlers.
          e.stopImmediatePropagation()
          return true
        
        changeSelection: (f) ->
          tbody = @$('.im-item-table tbody')[0]
          @items.each (item) -> item.facetRow?.remove()
          @items.each (item) =>
            f.call(@, item)
            _.defer => tbody.appendChild @makeRow item
          @items.trigger 'change:selected'

        resetOptions: (e) -> @changeSelection (item) -> item.set({selected: false}, {silent: true})

        toggleSelection: (e) -> @changeSelection (item) ->
          item.set({selected: not item.get('selected')}, {silent: true}) if item.get('visibility')

        addConstraint: (e, ops, vals) ->
          e.preventDefault()
          e.stopPropagation()
          newCon = path: @facet.path
          unless vals?
            vals = (item.get "item" for item in @items.where selected: true)
            unselected = @items.where selected: false
            if (not @hasMore) and vals.length > unselected.length
              return @addConstraint e, negateOps(ops), (item.get('item') for item in unselected)

          if vals.length is 1
            if vals[0] is null
                newCon.op = ops.absent
            else
                newCon.op = ops.single
                newCon.value = "#{vals[0]}"
          else
              newCon.op = ops.multi
              newCon.values = vals
          newCon.title = @facet.title unless @facet.ignoreTitle
          @query.addConstraint newCon

        render: ->
          @addChart()
          @addControls()
          this

        addChart: ->
          if d3?
            @_drawD3Chart()
          # Boo-hoo, can't draw a pretty chart.
          this

        _drawD3Chart: ->
          h = @chartHeight
          w = @$el.closest(':visible').width()
          r = h * 0.4
          ir = h * 0.1
          donut = d3.layout.pie().value (d) -> d.get 'count'

          {PieColors} = intermine.options
          if _.isFunction PieColors
            paint = PieColors
          else
            paint = d3.scale[PieColors]()

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
            $(@).tooltip {title, placement, container: elem}
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

        filterControls: """
          <div class="input-prepend">
              <span class="add-on"><i class="icon-refresh"></i></span><input type="text" class="input-medium  filter-values" placeholder="Filter values">
          </div>
        """

        getDownloadPopover: ->
          {icons} = intermine
          lis = for param, name of SUMMARY_FORMATS
            href = """#{ @query.getExportURI param }&summaryPath=#{ @facet.path }"""
            i = """<i class="#{ icons[name] }"></i>"""
            """<li><a href="#{ href }"> #{ i } #{ name }</a></li>"""

          """<ul class="im-export-summary">#{ lis.join '' }</ul>"""

        addControls: ->
            {More, DownloadData, DownloadFormat} = intermine.messages.facets
            $grp = $ """
            <form class="form form-horizontal">
              #{ @filterControls }
              <div class="im-item-table">
                <table class="table table-condensed table-striped">
                  <colgroup>
                    #{ @colClasses.map( (cl) -> "<col class=#{cl}>").join('') }
                  </colgroup>
                  <thead>
                    <tr>#{ @columnHeaders.map( (h) -> "<th>#{ h }</th>" ).join('') }</tr>
                  </thead>
                  <tbody class="scrollable"></tbody>
                </table>
                #{ if @hasMore then '<div class="im-load-more">' + More + '</div>' else '' }
              </div>
            </form>"""
            $grp.button()
            tbody = $grp.find('tbody')[0]
            @items.each (item) => @addItemRow item, @items, {}, tbody
            $grp.append """
              <button class="btn pull-right im-download">
                <i class="#{ intermine.icons.Download }"></i>
                #{ DownloadData }
              </button>
              <div class="im-filter btn-group">
                #{ @buttons }
              </div>
            """

            $btns = $grp.find('.btn').tooltip placement: 'top'
            $btns.on 'click', (e) -> $btns.tooltip 'hide'

            $grp.find('.im-download').popover
              placement: 'top'
              html: true
              container: @el
              title: DownloadFormat
              content: @getDownloadPopover()
              trigger: 'click'

            @initFilter()

            $grp.appendTo @el

            this

        addItemRow: (item, items, opts, tbody) ->
          tbody ?= @$('.im-item-table tbody').get()[0]
          tbody.appendChild @makeRow item

        buttons: """
          <button type="submit" class="btn btn-primary im-filter-in" disabled
                  title="Filter the table to only matching rows">
            Filter
          </button>
          <button type="submit" class="btn btn-primary im-filter-out"
                  title="Filter the table to exclude all matching rows"  disabled>
            Filter Out
          </button>
          <button class="btn btn-cancel" disabled title="Reset selection">
            <i class="#{ intermine.icons.Undo }"></i>
          </button>
          <button class="btn btn-toggle-selection" title="Toggle selection">
            <i class="#{ intermine.icons.Toggle }"></i>
          </button>
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
          row.render().el
            

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
            @item.facetRow = @
            @listenTo @item, "change:selected", => @onChangeSelected()
            @listenTo @item, "change:visibility", => @onChangeVisibility()

            @listenTo @item, 'hover', =>
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

            @listenTo @item, 'unhover', =>
                @$el.removeClass 'hover'
                s = @$el.closest('.im-item-table').find('.im-facet-surrogate').fadeOut 'fast', () ->
                    s.remove()

        initState: ->
          @onChangeVisibility()
          @onChangeSelected()

        onChangeVisibility: ->
          @$el.toggle @item.get "visibility"

        onChangeSelected: ->
          isSelected = !!@item.get "selected"
          if @item.has "path"
              item.get("path").node.setAttribute "class", if isSelected then "selected" else ""
          @$el.toggleClass "active", isSelected
          if isSelected isnt @$('input').attr("checked")
              @$('input').attr "checked", isSelected

        events:
            'click': 'handleClick'
            'change input': 'handleChange'

        render: ->
            ratio = parseInt(@item.get("count"), 10) / @items.maxCount
            opacity = ratio.toFixed(2) / 2 + 0.5
            percent = (ratio * 100).toFixed(1)

            # TODO: there is a hard coded color here - this should live in css somehow.
            @$el.append """
                <td class="im-selector-col">
                    <span>#{ ((@item.get "symbol") || "") }</span>
                    <input type="checkbox">
                </td>
                <td class="im-item-col">
                  #{@item.get("item") ? '<span class=null-value>&nbsp;</span>' }
                </td>
                <td class="im-count-col">
                    <div class="im-facet-bar"
                         style="width:#{percent}%;background:rgba(206, 210, 222, #{opacity})">
                      <span class="im-count">
                        #{@item.get "count"}
                      </span>
                    </div>
                </td>
            """
            if @item.get "percent"
                @$el.append """<td class="im-prop-col"><i>#{@item.get("percent").toFixed()}%</i></td>"""

            @initState()

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
