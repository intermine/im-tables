do ->

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


    class SubTable extends Backbone.View
        tagName: "td"
        className: "im-result-subtable"

        initialize: ->
            @query = @options.query
            @cellify = @options.cellify
            @path = @options.node
            subtable = @options.subtable
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
                    # find the outer join:
                    level = if @query.isOuterJoined(@view[0])
                        @query.getPathInfo(@query.getOuterJoin(@view[0]))
                    else
                        @column
                    """No #{ level.getType().name }"""
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
                        if intermine.results.shouldFormat(path)
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
                      view = @cellify cell
                      if intermine.results.shouldFormat view.path
                        view.formatter = intermine.results.getFormatter view.path
                      else
                      tr.append view.el
                      view.render().setWidth w
                    t.children('tbody').append tr
                    null

                if @column.isCollection()
                    appendRow(t, row) for row in @rows
                else
                    appendRow(t, @rows[0]) # Odd hack to fix multiple repeated rows.


            t.addClass 'im-subtable table table-condensed table-striped'

            @$el.append t

            summary.css(cursor: 'pointer').click (e) =>
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
            # @$el.css width: (w * @view.length) + "px"
            # @$('.im-cell-link').css "max-width": ((w * @view.length) - 5) + "px"
            this

    class Cell extends Backbone.View
        tagName: "td"
        className: "im-result-field"

        getUnits: () -> 1

        formatter: (model) -> model.escape @options.field

        events:
            'click': 'activateChooser'

        initialize: ->
            @model.on "change:selected", (model, selected) =>
                @$el.toggleClass "active", selected
                @$('input').attr checked: selected
            @model.on "change:selectable", (model, selectable) =>
                @$('input').attr disabled: !selectable
            @model.on 'change', @updateValue
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

            field = @options.field
            path = @path = @options.node.append field
            @$el.addClass 'im-type-' + path.getType().toLowerCase()

      
        # TODO: this should be its own view.
        getPopoverContent: ->
          return @model.cachedPopover if @model.cachedPopover?

          type = @model.get '_type'
          id = @model.get 'id'

          popover = new intermine.table.cell.Preview
            service: @options.query.service
            schema: @options.query.model
            model: {type, id}

          content = popover.el
          working = $.Deferred()

          popover.on 'ready', -> working.resolve()
          popover.render()

          @model.cachedPopover = [content, working.promise()]
          

        setupPreviewOverlay: ->
          @$el.popover
            container: @el
            html: true
            placement: (popover) =>
                $(popover).addClass 'im-cell-preview bootstrap'
                table = @$el.closest "table"
                {left} = @$el.offset()
                w = @$el.width()
                if left + w + 400 <= table.offset().left + table.width()
                    return 'right'
                if table.offset().left <= left - 400
                    return 'left'
                else
                    return "bottom"
            title: @model.get '_type'
            trigger: "hover"
            delay: {show: 500, hide: 100}
            content: =>
                unless @content
                  [@content, ready] = @getPopoverContent()
                  ready.done => @$el.popover 'show'

                @content


        updateValue: => @$('.im-cell-link').html @formatter(@model)

        render: ->
            id = @model.get "id"
            field = @options.field
            data =
              value: @model.get field
              field: field

            _.defaults data, @model.toJSON(), {'_type': ''}
            html = CELL_HTML data

            @$el.append(html)
                .toggleClass(active: @model.get "selected")

            @updateValue()

            @setupPreviewOverlay() if id?
            this

        setWidth: (w) ->
          #@$el.css width: w + "px"
          #  @$('.im-cell-link').css "max-width": (w - 5) + "px"
          this

        activateChooser: ->
            if @model.get "selectable"
                @model.set selected: !@model.get("selected") if @$('input').is ':visible'

    class NullCell extends Cell
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

    scope "intermine.results.table", {NullCell, SubTable, Cell}

