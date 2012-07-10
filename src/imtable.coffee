scope "intermine.css", {
    unsorted: "icon-sort",
    sortedASC: "icon-sort-up",
    sortedDESC: "icon-sort-down",
    headerIcon: "icon-white"
    headerIconRemove: "icon-remove-sign"
    headerIconHide: "icon-minus-sign"
    headerIconFilter: "icon-filter"
    headerIconSummary: "icon-bar-chart"
}

scope 'intermine.messages.query', {
    # A function of the form ({count: i, first: i, last: i, roots: str}) -> str
    CountSummary: _.template """
          <span class="im-only-widescreen">Showing</span>
          <span>
            <% if (last == 0) { %>
                All
            <% } else { %>
                <%= first %> to <%= last %> of
            <% } %>
            <%= count %> <%= roots %>
          </span>
        """
}

scope "intermine.query.results", (exporting) ->

    NUMERIC_TYPES = ["int", "Integer", "double", "Double", "float", "Float"]

    class Page
        constructor: (@start, @size) ->
        end: -> @start + @size

    class ResultsTable extends Backbone.View

        @nextDirections =
            ASC: "DESC"
            DESC: "ASC"
        className: "im-results-table table table-striped table-bordered"
        tagName: "table"
        attributes:
            width: "100%"
            cellpadding: 0
            border: 0
            cellspacing: 0
        pageSize: 25
        pageStart: 0
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

        initialize: (@query, @getData) ->
            @minimisedCols = {}
            @query.on "set:sortorder", (oes) =>
                @lastAction = 'resort'
                @fill()
            @query.on "page-size:selected", (size) =>
                @pageSize = size
                @pageStart = 0 if (size is 0)
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
                    tr.append(cell.render().setWidth(w).$el)
            tr.appendTo @el

        errorTempl: _.template """
            <div class="alert alert-error">
                <h2>Oops!</h2>
                <p><i><%- error %></i></p>
            </div>
        """

        handleError: (err, time) =>
            notice = $ @errorTempl error: err
            notice.append """<p>Time: #{ time }</p>""" if time?
            notice.append """<p>
                This is most likely related to the query that was just run. If you have
                time, please send us an email with details of this query to help us diagnose and
                fix this bug.
            </p>"""
            btn = $ '<button class="btn btn-error">'
            notice.append btn
            p = $ '<p style="display:none" class="well">'
            btn.text 'show query'
            p.text @query.toXML()
            btn.click () -> p.slideToggle()
            mailto = @query.service.help + "?" + $.param {
                subject: "Error running embedded table query"
                body: """
                    We encountered an error running a query from an
                    embedded result table.
                    
                    page:       #{ window.location }
                    service:    #{ @query.service.root }
                    error:      #{ err }
                    date-stamp: #{ time }
                    query:      #{ @query.toXML() }
                """
            }, true
            mailto = mailto.replace(/\+/g, '%20') # stupid jquery 'wontfix' indeed. grumble
            notice.append """<a class="btn btn-primary pull-right" href="mailto:#{ mailto }">
                    Email the help-desk
                </a>"""
            notice.append p
            @$el.append notice
            

        columnHeaderTempl: (ctx) -> _.template """
            <th>
                <div class="navbar">
                    <div class="im-th-buttons">
                        <% if (sortable) { %>
                            <div class="im-th-button im-col-sort-indicator" title="sort this column">
                                <i class="icon-sorting #{intermine.css.unsorted} #{ intermine.css.headerIcon }"></i>
                            </div>
                        <% }; %>
                        <div class="im-th-button im-col-remover" title="remove this column" data-view="<%= view %>">
                            <i class="#{ intermine.css.headerIconRemove } #{ intermine.css.headerIcon }"></i>
                        </div>
                        <div class="im-th-button im-col-minumaximiser" title="Hide column" data-col-idx="<%= i %>">
                            <i class="#{ intermine.css.headerIconHide } #{ intermine.css.headerIcon }"></i>
                        </div>
                        <div class="dropdown im-filter-summary">
                            <div class="im-th-button im-col-filters dropdown-toggle"
                                 title="Filter by values in this column"
                                 data-toggle="dropdown" data-col-idx="<%= i %>" >
                                <i class="#{ intermine.css.headerIconFilter } #{ intermine.css.headerIcon }"></i>
                            </div>
                            <div class="dropdown-menu">
                                <div>Could not ititialise the filter summary.</div>
                            </div>
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

        buildColumnHeader: (view, i, title, tr) ->
            q = @query
            direction = q.getSortDirection(view)
            sortable = !q.isOuterJoined(view)
            th = $ @columnHeaderTempl
                title: title
                i: i
                view: view
                sortable: sortable
                
            tr.append th
            
            if _.any q.constraints, ((c) -> !!c.path.match(view))
                th.addClass 'im-has-constraint'
                th.find('.im-col-filters').attr title: """#{ _.size(_.filter(q.constraints, (c) -> !!c.path.match(view))) } active filters"""
            th.find('.im-th-button').tooltip(placement: "left")
            sortButton = th.find('.icon-sorting')
            setDirectionClass = (d) ->
                sortButton.addClass(intermine.css.unsorted)
                sortButton.removeClass("#{ intermine.css.sortedASC } #{ intermine.css.sortedDESC }")
                if d
                    sortButton.toggleClass("#{ intermine.css.unsorted } #{ intermine.css['sorted' + d] }")

            setDirectionClass(direction)
            @query.on "set:sortorder", ->
                sd = q.getSortDirection(view)
                setDirectionClass(sd)

            direction = (ResultsTable.nextDirections[ direction ] or "ASC")
            sortButton.parent().click (e) ->
                $elem = $ this
                #if e.shiftKey # allow multiple orders?
                #    q.addOrSetSortOrder
                #        path: view
                #        direction: direction
                #else
                q.orderBy([{path: view, direction: direction}])
                direction = ResultsTable.nextDirections[ direction ]
            minumaximiser = th.find('.im-col-minumaximiser')
            minumaximiser.click (e) =>
                minumaximiser.find('i').toggleClass("icon-minus-sign icon-plus-sign")
                isMinimised = @minimisedCols[i] = !@minimisedCols[i]
                th.find('.im-col-title').toggle(!isMinimised)
                @fill()
            filterSummary = th.find('.im-col-filters')
            filterSummary.click(@showFilterSummary(view)).dropdown()
            path = q.getPathInfo view
            if path.isAttribute()
                th.find('.summary-img').click(@showColumnSummary(path)).dropdown()
            else
                th.find('.summary-img').click(@showOuterJoinedColumnSummaries(path)).dropdown()
                expandAll = $ """<div class="im-th-button" title="Expand/Collapse all subtables">
                    <i class="icon-table icon-white"></i>
                </div>"""
                expandAll.tooltip placement: 'left'
                th.find('.im-th-buttons').prepend expandAll
                cmds = ['expand', 'collapse']
                cmd = 0
                @query.on 'subtable:expanded', (node) ->
                    if node.toString().match path.toString()
                        cmd = 1
                @query.on 'subtable:collapsed', (node) ->
                    if node.toString().match path.toString()
                        cmd = 0
                expandAll.click (e) =>
                    e.stopPropagation()
                    e.preventDefault()
                    @query.trigger "#{cmds[cmd]}:subtables", path
                    cmd = (cmd + 1) % 2

        addColumnHeaders: (result) =>
            thead = $ "<thead>"
            tr = $ "<tr>"
            thead.append tr
            q = @query
            if result.results.length and _.has(result.results[0][0], 'column')
                views = result.results[0].map (row) -> row.column
                promise = new $.Deferred()
                titles = {}
                _.each views, (v) ->
                    path = q.getPathInfo(v)
                    if (path.end?.name is 'id') and intermine.results.getFormatter(q.model, path.getParent().getType())?
                        path = path.getParent()
                    path.getDisplayName (name) ->
                        titles[v] = name
                        if _.size(titles) is views.length
                            promise.resolve titles
                promise.done (titles) =>
                    for v, i in views
                        @buildColumnHeader v, i, titles[v], tr
            else
                views = q.views
                for view, i in views then do (view, i) =>
                    title = result.columnHeaders[i].split(' > ').slice(1).join(" > ")
                    @buildColumnHeader view, i, title, tr

                    
            thead.appendTo @el

        showOuterJoinedColumnSummaries: (path) -> (e) =>
            $el = jQuery(e.target).closest '.summary-img'
            unless $el.parent().hasClass 'open'
                summ = new intermine.query.results.OuterJoinDropDown(path, @query)
                $el.siblings('.dropdown-menu').html(summ.render().el)

            false

        checkHowFarOver: (e) ->
            thb = $(e.target).closest '.im-th-button'
            bounds = thb.closest '.im-table-container'
            if (thb.offset().left + 350) >= (bounds.offset().left + bounds.width())
                thb.closest('th').addClass 'too-far-over'

        showFilterSummary: (path) -> (e) =>
            @checkHowFarOver(e)
            $el = jQuery(e.target).closest '.im-col-filters'
            unless $el.parent().hasClass 'open'
                summ = new intermine.query.filters.SingleColumnConstraints(@query, path)
                $el.siblings('.dropdown-menu').html(summ.render().el)

            false

        showColumnSummary: (path) -> (e) =>
            @checkHowFarOver(e)
            $el = jQuery(e.target).closest '.summary-img'

            view = path.toString()
            unless view
                e.stopPropagation()
                e.preventDefault()
            else unless $el.parent().hasClass "open"
                summ = new intermine.query.results.DropDownColumnSummary(view, @query)
                $el.siblings('.dropdown-menu').html(summ.render().el)

            false

    class PageSizer extends Backbone.View

        tagName: 'form'
        className: "im-page-sizer form-horizontal"
        sizes: [[10], [25], [50], [100], [0, 'All']]

        initialize: (@query, @pageSize) ->
            if @pageSize?
                unless _.include @sizes.map( (s) -> s[0] ), @pageSize
                    @sizes.unshift [@pageSize, @pageSize]
            else
                @pageSize = @sizes[0][0]

        render: () ->
            @$el.append """
                <label>
                    <span class="im-only-widescreen">Rows per page:</span>
                    <select class="span1" title="Rows per page">
                    </select>
                </label>
            """
            select = @$('select')
            for ps in @sizes
                select.append @make 'option', {value: ps[0], selected: ps[0] is @pageSize}, (ps[1] or ps[0])
            select.change (e) =>
                @query.trigger "page-size:selected", parseInt(select.val())
            this

    exporting class Table extends Backbone.View

        className: "im-table-container"

        paginationTempl: _.template """
            <div class="pagination pagination-right">
                <ul>
                    <li title="Go to start">
                        <a class="im-pagination-button" data-goto=start>&#x21e4;</a>
                    </li>
                    <li title="Go back five pages">
                        <a class="im-pagination-button" data-goto=fast-rewind>&#x219e;</a>
                    </li>
                    <li title="Go to previous page">
                        <a class="im-pagination-button" data-goto=prev>&larr;</a>
                    </li>
                    <li class="im-current-page">
                        <a data-goto=here  href="#">&hellip;</a>
                        <form style="display:none;"><select></select></form>
                    </li>
                    <li title="Go to next page">
                        <a class="im-pagination-button" data-goto=next>&rarr;</a>
                    </li>
                    <li title="Go forward five pages">
                        <a class="im-pagination-button" data-goto=fast-forward>&#x21a0;</a>
                    </li>
                    <li title="Go to last page">
                        <a class="im-pagination-button" data-goto=end>&#x21e5;</a>
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
                @query.orderBy (for i in [0 ... noOfSortColumns] then do (i) =>
                    displayed = intermine.utils.getParameter(params, "iSortCol_" + i)
                    so =
                        path: @query.views[viewIndices[displayed]]
                        direction: intermine.utils.getParameter(params, "sSortDir_" + i)
                    so)

        showError: (resp) =>
            try
                data = JSON.parse(resp.responseText)
                @table?.handleError(data.error, data.executionTime)
            catch err
                @table?.handleError("Internal error", new Date().toString())


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
                    size  <= 0

            promise = new jQuery.Deferred()
            if isStale or isOutOfRange
                page = @getPage start, size
                @overlayTable()

                req = @query[@fetchMethod] page, (rows, resultSet) =>
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
            jQuery('.im-table-overlay').remove()
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
                page.size = '' ## understood by server as all.

            # TODO - don't fill in gaps when it is too big (for some configuration of too big!)
            # Don't permit gaps, if the query itself conforms with the cache.
            if page.size && (page.end() < @cache.lowerBound)
                if (@cache.lowerBound - page.end()) > (page.size * 10)
                    @cache = {} # dump cache
                    page.size *= 2
                    return page
                else
                    page.size = @cache.lowerBound - page.start

            if @cache.upperBound < page.start
                if (page.start - @cache.upperBound) > (page.size * 10)
                    @cache = {} # dump cache
                    page.size *= 2
                    page.start = Math.max(0, page.start - (size * @_pipe_factor))
                    return page
                if page.size
                    page.size += page.start - @cache.upperBound
                # Extend towards cache limit
                page.start = @cache.upperBound

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
                @cache.lowerBound = result.start
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
            html    = intermine.messages.query.CountSummary
                first: start + 1
                last: if (size is 0) then 0 else Math.min(start + size, result.iTotalRecords)
                count: intermine.utils.numToString(result.iTotalRecords, ",", 3)
                roots: "rows"
            summary.html html
            @query.trigger 'count:is', result.iTotalRecords

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
            result.results.splice(size, result.results.length) if (size > 0)


            @updateSummary start, size, result

            # TODO - make sure cells know their node...

            fields = ([@query.getPathInfo(v).getParent(), v.replace(/^.*\./, "")] for v in result.views)

            makeCell = (obj) =>
                if _.has(obj, 'rows')
                    return new intermine.results.table.SubTable(@query, makeCell, obj)
                else
                    node = @query.getPathInfo(obj.column).getParent()
                    field = obj.column.replace(/^.*\./, '')
                    model = if obj.id?
                        @itemModels[obj.id] or= (new intermine.model.IMObject(@query, obj, field, base))
                    else if not obj.class?
                        new intermine.model.NullObject @query, field
                    else
                        new intermine.model.FPObject(@query, obj, field, node.getType().name)
                    model.merge obj, field
                    args = {model, node, field}
                    args.query = @query
                    return new intermine.results.table.Cell(args)

            result.rows = result.results.map (row) =>
                (row).map (cell, idx) =>
                    if _.has(cell, 'column') # dealing with new-style tableRows here.
                        makeCell(cell)
                    else if cell?.id?
                        field = fields[idx]
                        imo = @itemModels[cell.id] or= (new intermine.model.IMObject(@query, cell, field[1], base))
                        imo.merge cell, field[1]
                        new intermine.results.table.Cell(
                            model: imo
                            node: field[0]
                            field: field[1]
                            query: @query
                        )
                    else if cell?.value?
                        new intermine.results.table.Cell( # FastPathObjects don't have ids, and cannot be in lists.
                            model: new intermine.model.FPObject(@query, cell, field[1])
                            query: @query
                            field: field[1]
                        )
                    else
                        new intermine.results.table.NullCell query: @query

            result

        tableAttrs:
            class: "table table-striped table-bordered"
            width: "100%"
            cellpadding: 0
            border: 0
            cellspacing: 0

        render: ->
            @$el.empty()

            tel = @make "table", @tableAttrs
            @$el.append tel
            jQuery(tel).append """
                <h2>Building table</h2>
                <div class="progress progress-striped active progress-info">
                    <div class="bar" style="width: 100%"></div>
                </div>
            """
            @query.service.fetchVersion(@doRender(tel)).fail @onSetupError(tel)

        doRender: (tel) -> (version) =>
            @fetchMethod = if version >= 10
                'tableRows'
            else
                'table'

            path = "query/results"
            setupParams =
                format: "jsontable"
                query: @query.toXML()
                token: @query.service.token
            @$el.appendTo @$parent
            @query.service.makeRequest(path, setupParams, @onSetupSuccess(tel), "POST").fail @onSetupError(tel)
            this

        events:
            'click .im-col-remover': 'removeColumn'

        removeColumn: (e) =>
            e.stopPropagation()
            e.preventDefault()
            $el = jQuery(e.target).closest '.im-col-remover'
            $el.tooltip("hide")
            view = $el.data "view"
            unwanted = (v for v in @query.views when (v.match(view)))
            @query.removeFromSelect unwanted
            false

        horizontalScroller: """
            <div class="scroll-bar-wrap well">
                <div class="scroll-bar-containment">
                    <div class="scroll-bar alert-info alert"></div>
                </div>
            </div>
        """

        onSetupSuccess: (telem) -> (result) =>
            $telem = jQuery(telem).empty()
            $widgets = $('<div>').insertBefore(telem)

            @table = new ResultsTable @query, @getRowData
            @table.setElement telem
            @table.pageSize = @pageSize if @pageSize?
            @table.pageStart = @pageStart if @pageStart?
            @table.render()
            @query.on "imtable:change:page", @updatePageDisplay


            pageSizer = new PageSizer(@query, @pageSize)
            pageSizer.render().$el.appendTo $widgets

            $pagination = $(@paginationTempl()).appendTo($widgets)
            $pagination.find('li').tooltip(placement: "left")

            $widgets.append """
                <span class="im-table-summary"></div>
            """

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

            reorderer = new intermine.query.results.table.ColumnOrderer(@query)
            reorderer.render().$el.appendTo($widgets)

            if @bar is 'horizontal'
                $scrollwrapper = $(@horizontalScroller).appendTo($widgets)
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
            $widgets.append """<div style="clear:both"></div>"""


        updatePageDisplay: (start, size) =>
            total = @cache.lastResult.iTotalRecords
            if size is 0
                size = total

            scrollbar = @$ '.scroll-bar-wrap'
            if scrollbar.length
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
            pageSelector.val(Math.floor(start / size))
            if maxPage <= 100
                for p in [0 .. maxPage]
                    pageSelector.append """
                        <option value="#{p}">p. #{p + 1}</option>
                    """
                pageSelector.show()
            else
                pageSelector.hide()
                inp = $("""<input type=text placeholder="go to page...">""").appendTo(pageForm).change ->
                    newSelectorVal = parseInt(inp.val().replace(/\s*/g, "")) - 1
                    tbl.goToPage newSelectorVal
                    centre.find('a').show()
                    pageForm.hide()

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

