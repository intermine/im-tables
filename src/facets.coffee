# Define expectations
#

root = exports ? this

unless root.console
    root.console =
        log: ->
        debug: ->
        error: ->


root.intermine ?= {}
root.intermine.results ?= {}

intermine = root.intermine

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

class intermine.results.ColumnSummary extends Backbone.View
    tagName: 'div'
    className: "im-column-summary"
    initialize: (@facet, @query) ->

    render: =>
        attrType = @query.getType @facet.path
        if attrType in intermine.Model.NUMERIC_TYPES
            clazz = intermine.results.NumericFacet
        else if attrType in intermine.Model.BOOLEAN_TYPES
            clazz = intermine.results.BooleanFacet
        else
            clazz = intermine.results.FrequencyFacet
        initalLimit = 20 # items
        fac = new clazz(@query, @facet, initalLimit)
        @$el.append fac.el
        fac.render()
        this

class intermine.results.FacetView extends Backbone.View
    tagName: "dl"
    initialize: (@query, @facet, @limit) ->

    render: ->
        @$dt = $(FACET_TITLE @facet).appendTo @el
        @$dt.click =>
            @$dt.siblings().slideToggle()
            @$dt.find('i').first().toggleClass 'icon-chevron-right icon-chevron-down'
        this


class intermine.results.FrequencyFacet extends intermine.results.FacetView
    render: ->
        super()
        promise = @query.summarise @facet.path, @limit, (items, total) =>
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
                pf = new intermine.results.PieFacet(@query, @facet, items)
                @$el.append pf.el
                pf.render()
            else
                hf = new intermine.results.HistoFacet(@query, @facet, items)
                @$el.append hf.el
                hf.render()

                #@addItem item for item in items
            $(@el).remove() if total <= 1
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


class intermine.results.NumericFacet extends intermine.results.FacetView
    className: "im-numeric-facet"

    render: ->
        super()
        @container = @make "div"
            class: "facet-content"
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


class intermine.results.PieFacet extends Backbone.View

    className: 'im-pie-facet'
    initialize: (@query, @facet, items) ->
        @items = new Backbone.Collection(items)
        @items.on "change:selected", =>
            @$('.im-filter .btn').attr "disabled", !@items.any((item) -> item.get "selected")

    events:
        'click .im-filter .btn-primary': 'addConstraint'
        'click .im-filter .btn-cancel': 'resetOptions'

    resetOptions: ->
        @items.each (item) -> item.set "selected", false

    addConstraint: (e) ->
        e.preventDefault()
        console.log @query, @facet
        @query.addConstraint
            path: @facet.path
            op: "ONE OF"
            values: (item.get "item" for item in @items.filter (item) -> item.get "selected")

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
            textdy = -(r * 0.8 * Math.cos textRads)
            textdx = r * 0.8 * Math.sin textRads
            t = @paper.text cx, cy, item.get "item"
            t.attr
                "font-size": "14px"
                "text-anchor": if textdx > 0 then "start" else "end"
            t.translate textdx, textdy
            # Lord knows why?? 
            t.translate 0, -(r * 1.5) if $.browser.webkit
            t.node.setAttribute "class", "pie-label"
            degs += 360 * prop
            t

        t.toFront() for t in texts
        this

    addControls: ->
        $grp = $("""
        <form class="form form-horizontal">
            <table class="table table-condensed">
                <thead>
                    <tr>#{ @columnHeaders }</tr>
                </thead>
                <tbody></tbody>
            </table>
        </form>""").appendTo @el
        $grp.button()
        @items.each (item) =>
            r = @makeRow item
            $grp.find('tbody').append r
        $grp.append """
            <div class="im-filter">
                <button type="submit" class="btn btn-primary" disabled>Filter</button>
                <button class="btn btn-cancel" disabled>Reset</button>
            </div>
        """
        this

    columnHeaders: """
        <th></th>
        <th>Item</th>
        <th>Count</th>
        <th></th>
    """

    makeRow: (item) ->
        row = new intermine.results.FacetRow(item, @items)
        return row.render().$el

class intermine.results.FacetRow extends Backbone.View

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

    events:
        'click': 'handleClick'
        'change input': 'handleChange'

    render: ->
        inputType = if @items.size() > 2 then "checkbox" else "radio"
        @$el.append """
            <td>
                <input type="#{inputType}">
            </td>
            <td>#{@item.get "item"}</td>
            <td>#{@item.get "count"}</td>
        """
        if @item.get "percent"
            @$el.append """<td><i>#{@item.get("percent").toFixed()}%</i></td>"""

        this

    handleClick: (e) ->
        if e.target.type isnt 'checkbox'
            @$('input').trigger "click"

    handleChange: (e) ->
        e.preventDefault()
        @item.set "selected", @$('input').attr 'checked'

class intermine.results.HistoFacet extends intermine.results.PieFacet

    columnHeaders: """
        <th></th>
        <th>Item</th>
        <th>Count</th>
    """
    
    addChart: ->
        h = 150
        hh = 120
        w = @$el.closest(':visible').width() * 0.95
        max = @items.first().get "count"
        return this if @items.all (i) -> i.get("count") is 1
        chart = @make "div"
        @$el.append chart
        @paper = Raphael chart, w, h
        stepWidth = w / @items.size()

        @items.each (item, i) =>
            prop = item.get("count") / max
            pathCmd = "M#{i * stepWidth},#{hh + 5} v-#{hh * prop} h#{stepWidth} v#{hh * prop} z"
            path = @paper.path pathCmd
            item.set "path", path

        this


class intermine.results.BooleanFacet extends intermine.results.NumericFacet
    handleSummary: (items) =>
        t = _(items).find (i) -> i.item is true
        f = _(items).find (i) -> i.item is false
        total = t.count + f.count
        @drawChart total, f.count
        @drawControls total, f.count

    drawChart: (total, subtotal) =>
        w = @$el.width()
        prop = subtotal / total
        rads = 2 * Math.PI * prop

        h = 110
        r = 45
        cx = w / 2
        cy = h / 2
        dy = r + (-r * Math.cos rads)
        dx = r * Math.sin rads

        tArc = if prop < 0.5 then 1 else 0
        fArc = if prop > 0.5 then 1 else 0
        # TODO: Replace this with an explosion from the centre.
        dcx = if prop < 0.25 then 0 else -5
        if prop < 0.25
            dcy = 10
        else if prop < 0.5
            dcy = 2
        else if prop is 0.5
            dcy = 0
        else
            dcy = -5

        fpath = "M#{cx},#{cy} v-#{r} a#{r},#{r} 0 #{fArc},1 #{dx},#{dy} z"
        @fpath = @paper.path fpath
        @fpath.node.setAttribute("class", "falses")
        tpath = "M#{cx + dcx},#{cy + dcy} v-#{r} a#{r},#{r} 0 #{tArc},0 #{dx},#{dy} z"
        @tpath = @paper.path(tpath)
        @tpath.node.setAttribute("class", "trues")
        @paper.text(cx - (r * 1.2), 30, "TRUE").attr
            "font-size": "16px"
            "text-anchor": "end"
        @paper.text(cx + (r * 1.2), 30, "FALSE").attr
            "font-size": "16px"
            "text-anchor": "start"

    drawControls: (total, trues) =>
        $(@container).append """
          <form class="form-inline">
            <div class="pull-right im-filter">
                <button class="btn btn-primary disabled">Filter</button>
                <button class="btn btn-cancel disabled">Reset</button>
            </div>
            <div class="btn-group" data-toggle="buttons-radio">
                <a href="#" class="btn im-trues">True</a>
                <a href="#" class="btn im-falses">False</a>
            </div>
          </form>
        """
        $(@container).find('.btn-group').button()
                     .find('.btn').click =>
                         $(@container).find('.im-filter .btn').removeClass "disabled"

        console.log $(@container).find('.btn-cancel')
        $(@container).find('.btn-cancel').click =>
            @tpath.node.setAttribute("class", "trues")
            @fpath.node.setAttribute("class", "falses")
            $(@container).find('.im-filter .btn').addClass "disabled"
            $(@container).find('.btn').removeClass "active"
        $(@container).find('.btn-primary').click =>
            @query.addConstraint
                path: @facet.path
                op: '='
                value: if $(@container).find('.im-trues').is('.active') then "true" else "false"
        $(@container).find('.im-trues').click (e) =>
            e.preventDefault()
            @tpath.node.setAttribute("class", "trues")
            @fpath.node.setAttribute("class", "disabled")
        $(@container).find('.im-falses').click (e) =>
            e.preventDefault()
            @fpath.node.setAttribute("class", "falses")
            @tpath.node.setAttribute("class", "disabled")



