scope "intermine.css", {
    headerIcon: "icon-white"
    headerIconRemove: "icon-remove-sign"
    headerIconHide: "icon-minus-sign"
    headerIconSummary: "icon-info-sign"
}

scope "intermine.query.results", (exporting) ->

    NUMERIC_TYPES = ["int", "Integer", "double", "Double", "float", "Float"]
    COUNT_HTML = _.template """<span>Showing <%= first %> to <%= last %> of <%= count %></span> <%= roots %>"""

    class Page
        constructor: (@start, @size) ->
        end: -> @start + @size

    class ResultsTable extends Backbone.View
        className: "im-results-table table table-striped table-bordered"
        tagName: "table"
        attributes:
            width: "100%"
            cellpadding: 0
            border: 0
            cellspacing: 0
        pageSize: 25
        pageStart: 0
        pageSizes: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
        throbber: _.template """
            <tr class="im-table-throbber">
                <td colspan="<%= colcount %>">
                    <h2>Requesting Data</h2>
                    <div class="progress progress-info progress-striped active">
                        <div class="bar" style="width: 100%"></div>
                    </div>
                </td>
            </tr>
        """
        pageSizeTempl: _.template """
            <%= pageSize %> rows per page
        """

        initialize: (@query, @getData) ->
            @minimisedCols = {}
            @query.on "set:sortorder", (oes) =>
                @fill()

        render: ->
            @$el.empty()
            promise = @fill()
            promise.done(@addColumnHeaders)

        goTo: (start) ->
            @pageStart = parseInt(start)
            @fill()

        goToPage: (page) ->
            @pageStart = page * @pageSize
            @fill()

        fill: () ->
            throbber = $ @throbber colcount: @query.views.length
            #throbber.appendTo @el

            promise = @getData @pageStart, @pageSize
            promise.then(@appendRows, @handleError).always -> throbber.remove()
            promise.done () =>
                @query.trigger "imtable:change:page", @pageStart, @pageSize
            promise

        appendRows: (res) =>
            @$("tbody > tr").remove()
            @appendRow(row) for row in res.rows
            @query.trigger "table:filled"

        minimisedColumnPlaceholder: _.template """
            <td class="im-minimised-col" style="width:<%= width %>px">&hellip;</td>
        """

        appendRow: (row) ->
            tr = $ "<tr>"
            minWidth = 10
            minimised = (k for k, v of @minimisedCols when v)
            w = 1 / (row.length - minimised.length) * (@$el.width() - (minWidth * minimised.length))
            for cell, i in row then do (cell, i) =>
                if @minimisedCols[i]
                    tr.append(@minimisedColumnPlaceholder(width: minWidth))
                else
                    tr.append(cell.render().$el.css(width: w + "px"))
            tr.appendTo @el

        errorTempl: _.template """
            <div class="alert alert-error">
                <h2>Error</h2>
                <p><%- error %>
            </div>
        """

        handleError: (err) => @$el.append @errorTempl error: err

        columnHeaderTempl: (ctx) -> _.template """
            <th title="<%- title %>">
                <div class="navbar">
                    <div class="im-th-buttons">
                        <% if (sortable) { %>
                            <div class="im-th-button im-col-sort-indicator" title="sort this column">
                                <i class="icon-resize-vertical #{ intermine.css.headerIcon }"></i>
                            </div>
                        <% }; %>
                        <div class="im-th-button im-col-remover" title="remove this column" data-view="<%= view %>">
                            <i class="#{ intermine.css.headerIconRemove } #{ intermine.css.headerIcon }"></i>
                        </div>
                        <div class="im-th-button im-col-minumaximiser" title="Hide column" data-col-idx="<%= i %>">
                            <i class="#{ intermine.css.headerIconHide } #{ intermine.css.headerIcon }"></i>
                        </div>
                        <div class="dropdown im-summary">
                            <div class="im-th-button summary-img dropdown-toggle" title="column summary"
                                data-toggle="dropdown" data-col-idx="<%= i %>" >
                                <i class="#{ intermine.css.headerIconSummary } #{ intermine.css.headerIcon }"></i>
                            </div>
                            <div class="dropdown-menu">
                                <div>Could not ititialise the column summary.</div>
                            </div>
                        </div>
                    </div>
                    <span class="im-col-title"><%- title %></span>
                </div>
            </th>
        """, ctx

        addColumnHeaders: (result) =>
            thead = $ "<thead>"
            tr = $ "<tr>"
            thead.append tr
            nextDirections =
                ASC: "DESC"
                DESC: "ASC"
            q = @query
            for view, i in q.views then do (view, i) =>
                title = result.columnHeaders[i].split(' > ').slice(1).join(" > ")
                direction = q.getSortDirection(view)
                sortable = !q.isOuterJoined(view)
                th = $ @columnHeaderTempl
                    title: title
                    i: i
                    view: view
                    sortable: sortable
                    
                tr.append th
                th.find('.im-th-button').tooltip(placement: "left")
                sortButton = th.find('.icon-resize-vertical')
                setDirectionClass = (d) ->
                    sortButton.addClass("icon-resize-vertical")
                    sortButton.removeClass("icon-arrow-up icon-arrow-down")
                    switch d
                        when 'ASC' then sortButton.toggleClass "icon-resize-vertical icon-arrow-up"
                        when 'DESC' then sortButton.toggleClass "icon-resize-vertical icon-arrow-down"

                setDirectionClass(direction)
                q.on "set:sortorder", ->
                    sd = q.getSortDirection(view)
                    setDirectionClass(sd) if sd

                direction = (nextDirections[ direction ] or "ASC")
                sortButton.click (e) ->
                    $elem = $ this
                    #if e.shiftKey # allow multiple orders?
                    #    q.addOrSetSortOrder
                    #        path: view
                    #        direction: direction
                    #else
                    q.orderBy([{path: view, direction: direction}])
                    tr.find('.im-col-sort-indicator i').removeClass "icon-arrow-up icon-arrow-down"
                    tr.find('.im-col-sort-indicator i').addClass "icon-resize-vertical"
                    switch direction
                        when "ASC" then sortButton.toggleClass "icon-resize-vertical icon-arrow-up"
                        when "DESC" then sortButton.toggleClass "icon-resize-vertical icon-arrow-down"
                    direction = nextDirections[ direction ]
                    console.log q.sortOrder
                minumaximiser = th.find('.im-col-minumaximiser')
                minumaximiser.click (e) =>
                    minumaximiser.find('i').toggleClass("icon-minus-sign icon-plus-sign")
                    isMinimised = @minimisedCols[i] = !@minimisedCols[i]
                    th.find('.im-col-title').toggle(!isMinimised)
                    @fill()
                    
            tr.find('.summary-img').click(@showColumnSummary).dropdown()
            thead.appendTo @el

        showColumnSummary: (e) =>
            $el = jQuery(e.target).closest '.summary-img'

            i = $el.data "col-idx"
            view = @query.views[i]
            unless view
                e.stopPropagation()
                e.preventDefault()
            else unless $el.parent().hasClass "open"
                summ = new intermine.query.results.DropDownColumnSummary(view, @query)
                $el.siblings('.dropdown-menu').html(summ.render().el)

            false

    exporting class Table extends Backbone.View

        className: "im-table-container"

        paginationTempl: _.template """
            <div class="pagination pagination-right">
                <ul>
                    <li title="Go to start">
                        <a class="im-pagination-button" data-goto=start href="#">&#x21e4;</a>
                    </li>
                    <li title="Go back five pages">
                        <a class="im-pagination-button" data-goto=fast-rewind href="#">&#x219e;</a>
                    </li>
                    <li title="Go to previous page">
                        <a class="im-pagination-button" data-goto=prev  href="#">&larr;</a>
                    </li>
                    <li class="im-current-page">
                        <a data-goto=here  href="#">&hellip;</a>
                        <form style="display:none;"><select></select></form>
                    </li>
                    <li title="Go to next page">
                        <a class="im-pagination-button" data-goto=next  href="#">&rarr;</a>
                    </li>
                    <li title="Go forward five pages">
                        <a class="im-pagination-button" data-goto=fast-forward href="#">&#x21a0;</a>
                    </li>
                    <li title="Go to last page">
                        <a class="im-pagination-button" data-goto=end   href="#">&#x21e5;</a>
                    </li>
                </ul>
            </div>
        """

        onDraw: =>
            @query.trigger("start:list-creation") if @__selecting
            @drawn = true

        refresh: =>
            @table?.remove()
            @drawn = false
            @render()

        initialize: (@query, selector) ->
            @cache = {}
            @itemModels = {}
            @_pipe_factor = 10
            @$parent = jQuery(selector)
            @__selecting = false
            @visibleViews = @query.views.slice()

            @query.on "change:views", =>
                @visibleViews = @query.views.slice()
                @refresh()

            @query.on "start:list-creation", => @__selecting = true
            @query.on "stop:list-creation", => @__selecting = false

            @query.on "change:constraints", @refresh
            @query.on "change:joins", @refresh
            @query.on "table:filled", @onDraw

        ##
        ## Set the sort order of a query so that it matches the parameters 
        ## passed from DataTables.
        ##
        ## @param params An array of {name: x, value: y} objects passed from DT.
        ##
        ##
        adjustSortOrder: (params) ->
            viewIndices = for i in [0 .. intermine.utils.getParameter(params, "iColumns")]
                intermine.utils.getParameter(params, "mDataProp_" + i)
            noOfSortColumns = intermine.utils.getParameter(params, "iSortingCols")
            if noOfSortColumns
                console.log noOfSortColumns
                @query.orderBy (for i in [0 ... noOfSortColumns] then do (i) =>
                    displayed = intermine.utils.getParameter(params, "iSortCol_" + i)
                    so =
                        path: @query.views[viewIndices[displayed]]
                        direction: intermine.utils.getParameter(params, "sSortDir_" + i)
                    console.log so
                    so)

        ##
        ## Function for buffering data for a request. Each request fetches a page of
        ## pipe_factor * size, and if subsequent requests request data within this range, then
        ##
        ## This function is used as a callback to the datatables server data method.
        ##
        ## @param src URL passed from DataTables. Ignored.
        ## @param param list of {name: x, value: y} objects passed from DataTables
        ## @param callback fn of signature: resultSet -> ().
        ##
        ##
        getRowData: (start, size) => # params, callback) =>
            end = start + size
            isOutOfRange = false

            freshness = @query.getSorting() + @query.getConstraintXML() + @query.views.join()
            isStale = (freshness isnt @cache.freshness)

            if isStale
                ## Invalidate the cache
                @cache = {}
            else
                ## We need new data if the range of this request goes beyond that of the 
                ## cached values, or if all results are selected.
                isOutOfRange = @cache.lowerBound < 0 or
                    start < @cache.lowerBound or
                    end   > @cache.upperBound or
                    size  < 0

            promise = new jQuery.Deferred()
            if isStale or isOutOfRange
                page = @getPage start, size
                @overlayTable()

                req = @query.table page, (rows, resultSet) =>
                    @addRowsToCache page, resultSet
                    @cache.freshness = freshness
                req.fail @showError
                req.done () => promise.resolve @serveResultsFromCache start, size
                req.always @removeOverlay
            else
                promise.resolve @serveResultsFromCache start, size

            return promise

        overlayTable: =>
            return unless @table and @drawn
            elOffset = @$el.offset()
            tableOffset = @table.$el.offset()
            @overlay = jQuery @make "div", class: "im-table-overlay discrete"
            @overlay.css
                top: elOffset.top
                left: elOffset.left
                width: @table.$el.outerWidth(true)
                height: (tableOffset.top - elOffset.top) + @table.$el.outerHeight()
            @overlay.append @make "h1", {}, "Requesting data..."
            @overlay.find("h1").css
                top: (@table.$el.height() / 2) + "px"
                left: (@table.$el.width() / 4) + "px"
            @overlay.appendTo 'body'
            _.delay (=> @overlay.removeClass "discrete"), 100

        removeOverlay: => @overlay?.remove()

        ##
        ## Get the page to request given the desired start and size.
        ##
        ## @param start the index of the first result the user actually wants to see.
        ## @param size The size of the dislay window.
        ##
        ## @return A page object with "start" and "size" properties set to include the desired
        ##         results, but also taking the cache into account.
        ##
        getPage: (start, size) ->
            page = new Page(start, size)
            unless @cache.lastResult
                ## Can ignore the cache
                page.size *= @_pipe_factor
                return page

            # When paging backwards - extend page towards 0.
            if start < @cache.lowerBound
                page.start = Math.max 0, start - (size * @_pipe_factor)

            if size > 0
                page.size *= @_pipe_factor
            else
                page.size = 0 ## understood by server as all.

            # TODO - don't fill in gaps when it is too big (for some configuration of too big!)
            # Don't permit gaps, if the query itself conforms with the cache.
            if page.size && (page.end() < @cache.lowerBound)
                # Extend towards 0
                page.size = @cache.lowerBound - page.start

            if @cache.upperBound < page.start
                if page.size isnt 0
                    page.size += page.start - @cache.lowerBound
                # Extend towards cache limit
                page.start = @cache.lowerBound

            return page

        ##
        ## Update the cache with the retrieved results. If there is an overlap 
        ## between the returned results and what is already held in cache, prefer the newer 
        ## results.
        ##
        ## @param page The page these results were requested with.
        ## @param result The resultset returned from the server.
        ##
        ##
        addRowsToCache: (page, result) ->
            unless @cache.lastResult
                @cache.lastResult = result
                @cache.lowerBound = page.start
                @cache.upperBound = page.end()
            else
                rows = result.results
                merged = @cache.lastResult.results.slice()
                # Add rows we don't have to the front
                if page.start < @cache.lowerBound
                    merged = rows.concat merged.slice page.end() - @cache.lowerBound
                # Add rows we don't have to the end
                if @cache.upperBound < page.end()
                    merged = merged.slice(0, (page.start - @cache.lowerBound)).concat(rows)

                @cache.lowerBound = Math.min @cache.lowerBound, page.start
                @cache.upperBound = Math.max @cache.upperBound, page.end()
                @cache.lastResult.results = merged

        updateSummary: (start, size, result) ->
            summary = @$ '.im-table-summary'
            html    = COUNT_HTML
                first: start + 1
                last: Math.min(start + size, result.iTotalRecords)
                count: intermine.utils.numToString(result.iTotalRecords, ",", 3)
                roots: "rows"
            summary.html html

        ##
        ## Retrieve the results from the results cache.
        ##
        ## @param echo The results table request control.
        ## @param start The index of the first result desired.
        ## @param size The page size
        ##
        serveResultsFromCache: (start, size) ->
            base = @query.service.root.replace /\/service\/?$/, ""
            result = jQuery.extend true, {}, @cache.lastResult
            # Splice off the undesired sections.
            result.results.splice(0, start - @cache.lowerBound)
            result.results.splice(size, result.results.length)

            @updateSummary start, size, result

            # TODO - make sure cells know their node...

            fields = ([@query.getPathInfo(v).getParent(), v.replace(/^.*\./, "")] for v in result.views)
            result.rows = result.results.map (row) =>
                (row).map (cell, idx) =>
                    cv = if cell.id
                        field = fields[idx]
                        imo = @itemModels[cell.id] or= (new intermine.model.IMObject(@query, cell, field[1], base))
                        imo.merge cell, field[1]
                        new intermine.results.table.Cell(
                            model: imo
                            node: field[0]
                            field: field[1]
                            query: @query
                        )
                    else
                        new intermine.results.table.NullCell()
                    cv
                    #cv.render().el

            result

        tableAttrs:
            class: "table table-striped table-bordered"
            width: "100%"
            cellpadding: 0
            border: 0
            cellspacing: 0

        render: ->
            @$el.empty()
            @$el.append """
                <div class="im-table-summary"></div>
            """

            tel = @make "table", @tableAttrs
            @$el.append tel
            jQuery(tel).append """
                <div class="progress progress-striped active progress-info">
                    <h2>Building table</h2>
                    <div class="bar" style="width: 100%"></div>
                </div>
            """
            path = "query/results"
            setupParams =
                format: "jsontable"
                query: @query.toXML()
                token: @query.service.token
            @$el.appendTo @$parent
            @query.service.makeRequest(path, setupParams, @onSetupSuccess(tel), "POST").fail @onSetupError(tel)
            this

        events:
            'click .summary-img': 'showColumnSummary'
            'click .im-col-remover': 'removeColumn'

        showColumnSummary: (e) =>
            $el = jQuery(e.target).closest '.summary-img'

            i = $el.data "col-idx"
            view = @query.views[i]
            unless view
                e.stopPropagation()
                e.preventDefault()
            else unless $el.parent().hasClass "open"
                summ = new intermine.query.results.DropDownColumnSummary(view, @query)
                $el.siblings('.dropdown-menu').html(summ.render().el)

            false

        removeColumn: (e) =>
            e.stopPropagation()
            $el = jQuery(e.target).closest '.im-col-remover'
            $el.tooltip("hide")
            view = $el.data "view"
            @query.removeFromSelect view
            false

        makeCol: (result) -> (view, i)  =>
            col =
                bVisible: view in @visibleViews
                sTitle: result.columnHeaders[i].split(" > ").slice(1).join(" &gt; ") + """
                    <span class="im-col-summary navbar dropdown pull-right">
                        <div class="im-th-button im-col-remover" title="remove this column" data-view="#{view}">
                            <i class="icon-remove-sign icon-white"></i>
                        </div>
                        <div class="im-th-button summary-img dropdown-toggle" title="column summary"
                            data-toggle="dropdown" data-col-idx="#{i}" >
                            <i class="icon-info-sign icon-white"></i>
                        </div>
                        <div class="dropdown-menu">
                            <div>Some content of some type or another.</div>
                        </div>
                    </span>
                """
                # \u03A3
                sName: view
                mDataProp: i

        horizontalScroller: """
            <div class="scroll-bar-wrap well">
                <div class="scroll-bar-containment">
                    <div class="scroll-bar alert-info alert"></div>
                </div>
            </div>
        """

        onSetupSuccess: (telem) -> (result) =>
            $telem = jQuery(telem).empty()

            reorderer = new intermine.query.results.table.ColumnOrderer(@query)
            reorderer.render().$el.insertBefore(telem)

            $pagination = $(@paginationTempl()).insertBefore(telem)
            $pagination.find('li').tooltip(placement: "left")
            pageSelector = $pagination.find('select').change =>
                @table.goToPage pageSelector.val()
                currentPageButton.show()
                pageSelector.parent().hide()
            currentPageButton = $pagination.find(".im-current-page a").click =>
                total = @cache.lastResult.iTotalRecords
                if @table.pageSize >= total
                    return false
                currentPageButton.hide()
                pageSelector.parent().show()

            $scrollwrapper = $(@horizontalScroller).insertBefore(telem)
            scrollbar = @$ '.scroll-bar'

            currentPos = 0
            scrollbar.draggable
                axis: "x"
                containment: "parent"
                stop: (event, ui) =>
                    scrollbar.removeClass("scrolling")
                    scrollbar.tooltip("hide")
                    @table.goTo currentPos
                start: -> $(this).addClass("scrolling")
                drag: (event, ui) =>
                    scrollbar.tooltip("show")
                    left = ui.position.left
                    total = ui.helper.closest('.scroll-bar-wrap').width()
                    currentPos = @cache.lastResult.iTotalRecords * left / total

            scrollbar.css(position: "absolute").parent().css(position: "relative")

            scrollbar.tooltip
                trigger: "manual"
                title: => "#{(currentPos + 1).toFixed()} ... #{(currentPos + @table.pageSize).toFixed()}"

            @table = new ResultsTable @query, @getRowData
            @table.setElement(telem)
            @table.render()

            @query.on "imtable:change:page", @updatePageDisplay

        updatePageDisplay: (start, size) =>
            total = @cache.lastResult.iTotalRecords

            scrollbar = @$ '.scroll-bar-wrap'

            #scrollbar.slider("option", {max: total}) #, step: size})
            totalWidth = scrollbar.width()

            proportion = size / total
            scrollbar.toggle size < total
            unit = totalWidth / total
            scaled = Math.max(totalWidth * proportion, 20)
            overhang = size - ((total - (size * Math.floor(total / size)) ) % size)
            scrollbar.find('.scroll-bar-containment').css width: totalWidth + (unit * overhang)
            handle = scrollbar.find('.scroll-bar').css width: scaled

            handle.animate
                left: unit * start

            tbl = @table
            buttons = @$('.im-pagination-button')
            buttons.filter('.direct').remove()
            buttons.unbind("click").each ->
                $elem = $ this
                whenEnabled = (f) -> () -> f() unless $elem.parent().is('.active')
                switch $elem.data("goto")
                    when "start"
                        $elem.click whenEnabled -> tbl.goTo(0)
                        $elem.parent().toggleClass "active", start is 0
                    when "prev"
                        $elem.click whenEnabled -> tbl.goTo(Math.max(0, start - size))
                        $elem.parent().toggleClass "active", start is 0
                    when "fast-rewind"
                        $elem.click whenEnabled -> tbl.goTo(Math.max(0, start - (5 * size)))
                        $elem.parent().toggleClass "active", start is 0
                    when "next"
                        $elem.click whenEnabled -> tbl.goTo(start + size)
                        $elem.parent().toggleClass "active", (start + size >= total)
                    when "fast-forward"
                        $elem.click whenEnabled -> tbl.goTo(start + (5 * size))
                        $elem.parent().toggleClass "active", (start + (5 * size) >= total)
                    when "end"
                        $elem.click whenEnabled -> tbl.goTo(Math.floor(total / size) * size)
                        $elem.parent().toggleClass "active", (start + size >= total)
            centre = @$('.im-current-page')
            centre.find('a').text("p. #{Math.floor(start / size) + 1}")
            centre.toggleClass "active", size >= total
            pageForm = centre.find('form')
            pageForm.find('input').remove()
            pageSelector = pageForm.find('select').empty()
            maxPage = Math.floor(total / size)
            for p in [0 .. maxPage]
                pageSelector.append """
                    <option value="#{p}">p. #{p + 1}</option>
                """
            pageSelector.val(Math.floor(start / size))
            if maxPage <= 100
                pageSelector.show()
            else
                pageSelector.hide()
                $("""<input type=text placeholder="go to page...">""").appendTo(pageForm).change ->
                    newSelectorVal = parseInt($(this).val().replace(/\s*/g, "")) - 1
                    pageSelector.val(newSelectorVal).change()
                    $(this).remove()

        onSetupError: (telem) -> (xhr) =>
            $(telem).empty()
            console.log "SETUP FAILURE", arguments
            notice = @make "div", {class: "alert alert-error"}
            explanation = """
                Could not load the data-table. The server may be down, or 
                incorrectly configured, or we could be pointed at an invalid URL.
            """

            if xhr?.responseText
                explanation = JSON?.parse(xhr.responseText).error or explanation
                parts = _(part for part in explanation.split("\n") when part?).groupBy (p, i) -> i > 0
                explanation = [
                    @make("span", {}, parts[false] + ""),
                    @make("ul", {}, (@make "li", {}, issue for issue in parts[true]))
                ]

            $(notice).append(@make("a", {class: "close", "data-dismiss": "alert"}, "close"))
                     .append(@make("strong", {}, "Ooops...! "))
                     .append(explanation)
                     .appendTo(telem)

