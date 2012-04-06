namespace "intermine.results", (public) ->

    ##----------------
    ## Returns a fn to calculate a point Z(x), 
    ## the Probability Density Function, on any normal curve. 
    ## This is the height of the point ON the normal curve.
    ## For values on the Standard Normal Curve, call with Mean = 0, StdDev = 1.
    NormalCurve = (mean, stdev) ->
        (x) ->
            a = x - mean
            Math.exp(-(a * a) / (2 * stdev * stdev)) / (Math.sqrt(2 * Math.PI) * stdev)

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

    public class ColumnSummary extends Backbone.View
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
            if attrType in intermine.Model.NUMERIC_TYPES
                clazz = NumericFacet
            else if attrType in intermine.Model.BOOLEAN_TYPES
                clazz = BooleanFacet
            else
                clazz = FrequencyFacet
            initalLimit = 20 # items
            fac = new clazz(@query, @facet, initalLimit)
            @$el.append fac.el
            fac.render()
            this

    public class FacetView extends Backbone.View
        tagName: "dl"
        initialize: (@query, @facet, @limit) ->
            @query.on "change:constraints", @render

        render: =>
            @$dt = $(FACET_TITLE @facet).appendTo @el
            @$dt.click =>
                @$dt.siblings().slideToggle()
                @$dt.find('i').first().toggleClass 'icon-chevron-right icon-chevron-down'
            this

    public class FrequencyFacet extends FacetView
        render: ->
            super()
            $progress = $ """
                <div class="progress progress-info progress-striped active">
                    <div class="bar" style="width:100%"></div>
                </div>
            """
            $progress.appendTo @el
            promise = @query.summarise @facet.path, @limit, (items, total) =>
                $progress.remove()
                @$dt.append " (#{total})"
                if total > @limit
                    more = $(MORE_FACETS_HTML).appendTo(@$dt)
                                        .tooltip( {placement: "left"} )
                                        .click (e) =>
                        e.stopPropagation()
                        got = @$('dd').length
                        show = @$('dd').first().is ':visible'
                        @query.summarise @facet.path, (items) =>
                            (@addItem item).toggle(show) for item in items[got..]
                        more.tooltip('hide').remove()

                if total <= 12 and not @query.canHaveMultipleValues @facet.path
                    pf = new PieFacet(@query, @facet, items)
                    @$el.append pf.el
                    pf.render()
                else
                    hf = new HistoFacet(@query, @facet, items)
                    @$el.append hf.el
                    hf.render()

                if total <= 1
                    @$el.empty().append """
                        All items are unique.
                    """

            promise.fail @remove
            this

        addItem: (item) =>
            $dd = $(FACET_TEMPLATE(item)).appendTo @el
            $dd.click =>
                @query.addConstraint
                    title: @facet.title
                    path: @facet.path
                    op: "="
                    value: item.item
            $dd


    public class NumericFacet extends FacetView

        events: # A bit heavy handed, admittedly, but otherwise datatables goes a bit mental...
            'click': (e) -> e.stopPropagation()

        className: "im-numeric-facet"

        render: ->
            super()
            @container = @make "div"
                class: "facet-content im-facet"
            @$el.append(@container)
            canvas = @make "div"
            $(@container).append canvas
            @paper = Raphael(canvas, @$el.width(), 120)
            promise = @query.summarise @facet.path, @handleSummary
            promise.fail @remove
            this

        handleSummary: (items) =>
            summary = items[0]
            @mean = parseFloat(summary.average)
            @dev = parseFloat(summary.stdev)
            @max = summary.max
            @min = summary.min
            @drawCurve()
            @drawSlider()

        drawSlider: =>
            $(@container).append """
                <label>Range:</label>
                <input type="text" class="im-range-min input-small" value="#{@min}">
                <span>...</span>
                <input type="text" class="im-range-max input-small" value="#{@max}">
                <button class="btn btn-primary disabled">Apply</button>
                <button class="btn btn-cancel disabled">Reset</button>
                <div class="slider"></div>
                """
            step = if @query.getType(@facet.path) in ["int", "Integer"] then 1 else 0.1
            $slider = @$('.slider').slider
                range: true
                min: @min
                max: @max
                values: [@min, @max]
                step: step
                slide: (e, ui) =>
                    changed = ui.values[0] > @min or ui.values[1] < @max
                    @$('.btn').toggleClass "disabled", !changed
                    @$('input.im-range-min').val ui.values[0]
                    @$('input.im-range-max').val ui.values[1]
            @$('.btn-cancel').click =>
                $slider.slider 'values', 0, @min
                $slider.slider 'values', 1, @max
                @$('input.im-range-min').val @min
                @$('input.im-range-max').val @max
                @$('.btn').addClass "disabled"
            @$('.btn-primary').click =>
                @query.constraints = _(@query.constraints).filter (c) =>
                    c.path != @facet.path
                @query.addConstraints [
                    {
                        path: @facet.path
                        op: ">="
                        value: @$('input.im-range-min').val()
                    },
                    {
                        path: @facet.path
                        op: "<="
                        value: @$('input.im-range-max').val()
                    }
                ]

        drawCurve: () =>
            if @max is @min
                $(@el).remove()
                return
            sections = ((@max - @min) / @dev).toFixed()
            w = @$el.width()
            h = 100
            pathCmd = "M1,100S"
            nc = NormalCurve(w / 2, w / sections)
            factor = 100 / nc(w / 2)
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
                vals = _.uniq([@mean - stdevs * @dev, @mean + stdevs * @dev])

                getPathCmd = (x) -> "M#{x},#{h}L#{x},#{f(x)}"
                drawDivider = (x) => @paper.path(getPathCmd(x))
                drawDivider x for x in xs

                for val, i in vals
                    if @min < val < @max
                        text = @paper.text(xs[i], 110, val.toFixed(2)).attr
                            "font-size": "16px"
                        if xs[i] <= 0
                            text.translate 16, 0
                        else if xs[i] >= w
                            text.translate -16, 0

            @paper.text(0 + 16, 30, @min).attr
                "font-size": "16px"
            @paper.text(w - 16, 30, @max).attr
                "font-size": "16px"


    public class PieFacet extends Backbone.View

        className: 'im-pie-facet im-facet'
        initialize: (@query, @facet, items) ->
            @items = new Backbone.Collection(items)
            @items.each (item) -> item.set "visibility", true

            @items.maxCount = @items.first().get "count"
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
            console.log @query, @facet
            newCon =
                path: @facet.path
                op: "ONE OF"
                values: (item.get "item" for item in @items.filter (item) -> item.get "selected")
            newCon.title = @facet.title unless @facet.ignoreTitle
            @query.addConstraint newCon

        render: -> @addChart().addControls()

        addChart: ->
            return this if @items.all (i) -> i.get("count") is 1
            h = 150
            w = @$el.closest(':visible').width()
            r = 50
            chart = @make "div"
            @$el.append chart
            @paper = Raphael chart, w, h
            cx = w / 2
            cy = h / 2

            total = @items.reduce ((a, b) -> a + b.get "count"), 0
            degs = 0
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
                path.rotate degs, cx, cy
                textRads = (Raphael.rad degs) + (rads / 2)
                textdy = -(r * 0.6 * Math.cos textRads)
                textdx = r * 0.6 * Math.sin textRads
                t = @paper.text cx, cy, item.get "item"
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

        addControls: ->
            $grp = $("""
            <form class="form form-horizontal">
                <div class="input-prepend">
                    <span class="add-on"><i class="icon-refresh"></i></span><input type="text" class="input-medium search-query filter-values" placeholder="Filter values">
                </div>
                <div class="im-item-table">
                    <table class="table table-condensed">
                        <thead>
                            <tr>#{ @columnHeaders }</tr>
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
                    <button type="submit" class="btn btn-primary" disabled>Filter</button>
                    <button class="btn btn-cancel" disabled>Reset</button>
                    <button class="btn btn-toggle-selection"></button>
                </div>
            """
            xs = @items
            $valFilter = $grp.find(".filter-values")
            $valFilter.keyup (e) ->
                pattern = new RegExp $(@).val(), "i"
                console.log pattern
                xs.each (x) -> x.set "visibility", pattern.test x.get("item")
            $valFilter.prev().click (e) ->
                $(@).next().val("")
                xs.each (x) -> x.set "visibility", true

            this

        columnHeaders: """
            <th class="im-selector-col"></th>
            <th class="im-item-col">Item</th>
            <th class="im-count-col">Count</th>
            <th class="im-prop-count"></th>
        """

        makeRow: (item) ->
            row = new FacetRow(item, @items)
            return row.render().$el

    public class FacetRow extends Backbone.View

        tagName: "tr"
        className: "im-facet-row"

        initialize: (@item, @items) ->
            @item.on "change:selected", =>
                isSelected = @item.get "selected"
                if @item.get "path"
                    item.get("path").node.setAttribute "class", if isSelected then "selected" else ""
                @$el.toggleClass "active", isSelected
                if isSelected isnt @$('input').attr("checked")
                    @$('input').attr "checked", isSelected

            @item.on "change:visibility", => @$el.toggle @item.get "visibility"

        events:
            'click': 'handleClick'
            'change input': 'handleChange'

        render: ->
            inputType = if @items.size() > 2 then "checkbox" else "radio"
            percent = (parseInt(@item.get("count")) / @items.maxCount * 100).toFixed()
            @$el.append """
                <td class="im-selector-col">
                    <input type="#{inputType}">
                </td>
                <td class="im-item-col">#{@item.get "item"}</td>
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
            e.preventDefault()
            @item.set "selected", @$('input').attr 'checked'

    public class HistoFacet extends PieFacet

        columnHeaders: """
            <th></th>
            <th>Item</th>
            <th>Count</th>
        """
        
        addChart: ->
            h = 75
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
                item.set "path", path

            this


    public class BooleanFacet extends NumericFacet
        handleSummary: (items) =>
            t = _(items).find (i) -> i.item is true
            f = _(items).find (i) -> i.item is false
            total = (t?.count or 0) + (f?.count or 0)
            @drawChart total, (f?.count or 0)
            @drawControls total, (f?.count or 0)

        drawChart: (total, subtotal) =>
            h = 120
            w = @$el.closest(':visible').width()
            r = 50
            cx = w / 2
            cy = h / 2

            fprop = subtotal / total
            tprop = 1 - fprop

            if fprop is 0 or fprop is 1
                @paper.circle cx, cy, r
                t = @paper.text cx, cy, (if fprop is 1 then "false" else "true") + " (#{total})"
                t.attr
                    "font-size": "16px"
                return this

            degs = 0

            texts = (for prop, i in [fprop, tprop] then do (prop, i) =>
                rads = 2 * Math.PI * prop
                arc = if 0.5 < prop < 1 then 1 else 0
                dy = r + (-r * Math.cos rads)
                dx = r * Math.sin rads
                cmd = "M#{cx},#{cy} v-#{r} a#{r},#{r} 0 #{arc},1 #{dx},#{dy} z"
                path = @paper.path cmd
                if i is 0 then @fpath = path else @tpath = path
                path.rotate degs, cx, cy
                textRads = (Raphael.rad degs) + (rads / 2)
                textdy = -(r * 1.1 * Math.cos textRads)
                textdx = r * 1.1 * Math.sin textRads
                num = if i is 0 then subtotal else total - subtotal
                t = @paper.text cx, cy, """#{if i is 0 then "false" else "true"} (#{num})"""
                t.attr
                    "font-size": "16px"
                    "text-anchor": if textdx > 0 then "start" else "end"
                t.translate textdx, textdy
                # Lord knows why?? - not needed if in absolute...
                if $.browser.webkit
                    t.translate 0, -(r * 1.5) unless @$el.offsetParent().filter( -> $(@).css("position") is "absolute").length
                degs += 360 * prop
                t
            )
            t.toFront for t in texts
            this

        drawControls: (total, trues) =>
            return this unless @fpath and @tpath

            c = $(@container).append """
            <form class="form-inline">
                <div class="btn-group" data-toggle="buttons-radio">
                    <a href="#" class="btn im-trues">True</a>
                    <a href="#" class="btn im-falses">False</a>
                </div>
                <div class="pull-right im-filter">
                    <button class="btn btn-primary disabled">Filter</button>
                    <button class="btn btn-cancel disabled">Reset</button>
                </div>
            </form>
            """

            c.find('.btn-group').button()
             .find('.btn').click (e) => c.find('.im-filter .btn').removeClass "disabled"
                
            # TODO: move all this into events.
            console.log "Added cancel event to: ", c.find('.btn-cancel').click (e) =>
                console.log "Cancelando"
                @tpath.node.setAttribute("class", "trues")
                @fpath.node.setAttribute("class", "falses")
                c.find('.im-filter .btn').addClass "disabled"
                c.find('.btn').removeClass "active"
            console.log "Added cancel event to: ", c.find('.btn-primary').click (e) =>
                console.log "PRIMARY!!", e
                @query.addConstraint
                    path: @facet.path
                    op: '='
                    value: if c.find('.im-trues').is('.active') then "true" else "false"

            handleTheTruth = (selPath) => (e) =>
                @tpath.node.setAttribute("class", "")
                @fpath.node.setAttribute("class", "")
                selPath.node.setAttribute("class", "selected")
                $(e.target).button 'toggle'
                
            c.find('.im-trues').click handleTheTruth(@tpath)
            c.find('.im-falses').click handleTheTruth(@fpath)



