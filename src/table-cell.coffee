# A set of functions of the signature:
#   (Backbone.Model, intermine.Query, jQuery) -> {value: string, field: string}
#
# Defining a formatter means that this function will be used to display data
# rather than the standard id being shown.
scope "intermine.results.formatters", {
    Manager: (model, query, $cell) ->
        id = model.get 'id'
        if (model.has('title') and model.has('name'))
            title = model.get 'title'
            name = model.get 'name'
            return {value: "#{title} #{name}", field: "id"}
        else
            query.service.findById 'Manager', id, (manager) ->
                display = "#{ manager.title } #{ manager.name }"
                model.set title: manager.title, name: manager.name
                $cell.find('.im-cell-link').text display
            return {value: id, field: "id"}
}

scope "intermine.results", {
    getFormatter:   (model, type) ->
        formatter = null
        type = type.name or type
        types = [type].concat model.getAncestorsOf(type)
        formatter or= intermine.results.formatters[t] for t in types
        return formatter
}

scope "intermine.results.table", (exporting) ->

    # </div>
    CELL_HTML = _.template """
            <input class="list-chooser" type="checkbox" style="display: none" data-obj-id="<%= id %>" 
                <% if (selected) { %>checked <% }; %>
                data-obj-type="<%= _type %>">
            <% if (value == null) { %>
                <span class="null-value">no value</span>
            <% } else { %>
                <% if (url != null && url.match(/^http/)) { %>
                  <a class="im-cell-link" href="<%= url %>">
                    <% if (!url.match(window.location.origin)) { %>
                        <i class="icon-globe"></i>
                    <% } %>
                <% } else { %>
                  <a class="im-cell-link" href="<%= base %><%= url %>">
                <% } %>
                    <%- value %>
                </a>
            <% } %>
            <% if (field == 'url') { %>
                <a class="im-cell-link external" href="<%= value %>"><i class="icon-globe"></i>link</a>
            <% } %>
    """

    HIDDEN_FIELDS = ["class", "objectId"]

    exporting class SubTable extends Backbone.View
        tagName: "td"
        className: "im-result-subtable"
        
        initialize: (@query, @cellify, subtable) ->
            @rows = subtable.rows
            @view = subtable.view
            @column = @query.getPathInfo(subtable.column)
            @query.on 'expand:subtables', (path) =>
                if path.toString() is @column.toString()
                    @$('.im-subtable').slideDown()
            @query.on 'collapse:subtables', (path) =>
                if path.toString() is @column.toString()
                    @$('.im-subtable').slideUp()

        getSummaryText: () ->
            if @column.isCollection()
                """#{ @rows.length } #{ @column.getType().name }s"""
            else
                # Single collapsed reference.
                if @rows.length is 0
                    """No #{ @column.getType().name }"""
                else
                    """#{@rows[0][0].value} (#{@rows[0][1 ..].map((c) -> c.value).join(', ')})"""

        render: () ->
            icon = if @rows.length > 0 then '<i class=icon-table></i>' else '<i class=icon-non-existent></i>'
            summary = $ """<span>#{ icon }&nbsp;#{ @getSummaryText() }</span>"""
            summary.addClass('im-subtable-summary').appendTo @$el
            t = $ '<table><thead><tr></tr></thead><tbody></tbody></table>'
            colRoot = @column.getType().name
            colStr = @column.toString()
            if @rows.length > 0
                for v in @view then do (v) =>
                    th = $ """<th>
                        <i class="#{intermine.css.headerIconRemove}"></i>
                        <span></span>
                    </th>"""
                    th.find('i').click (e) => @query.removeFromSelect v
                    path = @query.getPathInfo(v)
                    @column.getDisplayName (colName) =>
                        span = th.find('span')
                        if (path.end?.name is 'id') and intermine.results.getFormatter(@query.model, path.getParent().getType())?
                            path = path.getParent()
                        path.getDisplayName (pathName) ->
                            if pathName.match(colName)
                                span.text pathName.replace(colName, '').replace(/^\s*>?\s*/, '')
                            else
                                span.text pathName.replace(/^[^>]*\s*>\s*/, '')
                    t.children('thead').children('tr').append th
                appendRow = (t, row) =>
                    tr = $ '<tr>'
                    w = @$el.width() / @view.length
                    for cell in row then do (tr, cell) =>
                        tr.append (@cellify cell).render().setWidth(w).el
                    t.children('tbody').append tr
                    null

                if @column.isCollection()
                    appendRow(t, row) for row in @rows
                else
                    appendRow(t, @rows[0]) # Odd hack to fix multiple repeated rows.


            t.addClass 'im-subtable table table-condensed table-striped'

            @$el.append t

            summary.css(cursor: 'pointer').click (e) =>
                console.log t
                e.stopPropagation()
                if t.is(':visible')
                    @query.trigger 'subtable:collapsed', @column
                else
                    @query.trigger 'subtable:expanded', @column
                t.slideToggle()

            this

        getUnits: () ->
            if @rows.length = 0
                @view.length
            else
                _.reduce(@rows[0], ((a, item) -> a + if item.view? then item.view.length else 1), 0)

        setWidth: (w) ->
            @$el.css width: (w * @view.length) + "px"
            @$('.im-cell-link').css "max-width": ((w * @view.length) - 5) + "px"
            this

    exporting class Cell extends Backbone.View
        tagName: "td"
        className: "im-result-field"

        getUnits: () -> 1

        events:
            'click': 'activateChooser'

        initialize: ->
            @model.on "change:selected", (model, selected) =>
                @$el.toggleClass "active", selected
                @$('input').attr checked: selected
            @model.on "change:selectable", (model, selectable) =>
                @$('input').attr disabled: !selectable
            @options.query.on "start:list-creation", =>
                @$('input').show() if @model.get "selectable"
            @options.query.on "stop:list-creation", =>
                @$('input').hide()
                @$el.removeClass "active"
                @model.set "selected", false

            @options.query.on "start:highlight:node", (node) =>
                if @options.node?.toPathString() is node.toPathString()
                    @$el.addClass "im-highlight"
            @options.query.on "stop:highlight", => @$el.removeClass "im-highlight"

        setupPreviewOverlay: () ->
            content = $ """
                <table class="im-item-details table table-condensed table-bordered">
                <colgroup>
                    <col class="im-item-field"/>
                    <col class="im-item-value"/>
                </colgroup>
                </table>
            """
            type = @model.get '_type'
            id = @model.get 'id'
            s = @options.query.service
            cellLink = @$el.find('.im-cell-link').first().popover
                placement: ->
                    table = cellLink.closest "table"
                    if cellLink.offset().left + + cellLink.width() + 300 >= table.offset().left + table.width()
                        return "left"
                    else
                        return "right"
                title: type
                trigger: "hover"
                delay: {show: 500, hide: 100}
                content: ->
                    unless cellLink.data "content"
                        s.findById type, id, (item) ->
                            for field, value of item when value and (field not in HIDDEN_FIELDS) and not value['objectId']
                                v = value + ""
                                v = if v.length > 100 then v.substring(0, 100) + "..." else v
                                content.append """
                                    <tr>
                                        <td>#{ field }</td>
                                        <td>#{ v }</td>
                                    </tr>
                                """
                            getLeaves = (o) ->
                                leaves = []
                                values = (leaf for name, leaf of o when name not in HIDDEN_FIELDS)
                                for x in values
                                    if x['objectId']
                                        leaves = leaves.concat(getLeaves(x))
                                    else
                                        leaves.push(x)
                                leaves
                                
                            for field, value of item when value and value['objectId']
                                values = getLeaves(value)
                                content.append """
                                    <tr>
                                        <td>#{ field }</td>
                                        <td>#{ values.join ', ' }</td>
                                    </tr>
                                """

                            cellLink.data content: content
                            cellLink.popover("show")

                    return content

        render: ->
            type = @model.get "_type"
            id = @model.get "id"
            # only id cells are subject to special format rules.
            if (@options.field is 'id') and (formatter = intermine.results.getFormatter(@options.query.model, type))
                data = formatter(@model, @options.query, @$el)
            else
                data = {value: @model.get(@options.field), field: @options.field}
            @$el.append(CELL_HTML _.extend {}, @model.toJSON(), data).toggleClass(active: @model.get "selected")
            @setupPreviewOverlay() if id?
            this

        setWidth: (w) ->
            @$el.css width: w + "px"
            @$('.im-cell-link').css "max-width": (w - 5) + "px"
            this

        activateChooser: ->
            if @model.get "selectable"
                @model.set selected: !@model.get("selected") if @$('input').is ':visible'

    exporting class NullCell extends Cell
        setupPreviewOverlay: ->

        initialize: ->
            @model = new Backbone.Model
                selected: false
                selectable: false
                value: null
                id: null
                url: null
                base: null
                _type: null
            super()



