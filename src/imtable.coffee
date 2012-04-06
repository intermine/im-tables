namespace "intermine.query.results", (public) ->

    ## Inline form fix: http://datatables.net/blog/Twitter_Bootstrap_2
    jQuery -> jQuery.extend jQuery.fn.dataTableExt.oStdClasses, {sWrapper: "dataTables_wrapper form-inline"}

    TABLE_INIT_PARAMS =
        sDom: "R<'row-fluid'<'span2 im-table-summary'><'pull-right'p><'pull-right'l>t<'row-fluid'<'span6'i>>"
        sPaginationType: "bootstrap"
        oLanguage:
            sLengthMenu: "_MENU_ rows per page"
            sProcessing: """
                <div class="progress progress-info progress-striped active">
                    <div class="bar" style="width: 100%"></div>
                </div>
            """
        aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
        iDisplayLength: 25
        bProcessing: false
        bServerSide: true

    NUMERIC_TYPES = ["int", "Integer", "double", "Double", "float", "Float"]
    COUNT_HTML = _.template """<span><%= count %></span> <%= roots %>"""

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
        pageSizes: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
        throbber: """
            <div class="progress progress-info progress-striped active">
                <div class="bar" style="width: 100%"></div>
            </div>
        """
        pageSizeTempl: _.template """
            <%= pageSize %> rows per page
        """

        initialize: (@query, @getData) ->

        render: ->
            @$el.empty()
            @addColumnHeaders()

            throbber = $ @throbber
            throbber.appendTo @el

            promise = @getData 0, @pageSize

            promise.then(@appendRows, @handleError).always -> throbber.remove()

        appendRows: (rows) => @appendRow(row) for row in rows

        appendRow: (row) ->
            tr = $ "<tr>"
            for cell in row then do (cell) ->
                tr.append(cell.render().el)
            tr.appendTo @el

        errorTempl: _.template """
            <div class="alert alert-error">
                <h2>Error</h2>
                <p><%= error %>
            </div>
        """

        handleError: (err) -> @$el.append @errorTempl error: err

        columnHeaderTempl: _.template """
            <th>
                <%- title %>
                <div class="im-th-button im-col-sort-indicator" title="sort this column">
                    <i class="icon-white"></i>
                </div>
                <div class="im-th-button im-col-remover" title="remove this column" data-view="<%= view %>">
                    <i class="icon-remove-sign icon-white"></i>
                </div>
                <div class="im-th-button summary-img dropdown-toggle" title="column summary"
                    data-toggle="dropdown" data-col-idx="<% i %>" >
                    <i class="icon-info-sign icon-white"></i>
                </div>
                <div class="dropdown-menu">
                    <div>Could not ititialise the column summary.</div>
                </div>
            </th>
        """

        addColumnHeaders: (result) -> () =>
            thead = $ "<thead>"
            tr = $ "<tr>"
            thead.append tr
            for view, i in @query.views
                title = result.columnHeaders[i].split(' > ').slice(1).join(" > ")
                th = @columnHeaderTempl title: title, i: i, view: view
                tr.append th

    public class Table extends Backbone.View

        className: "im-table-container"

        onDraw: =>
            @query.trigger("start:list-creation") if @__selecting

            unless @drawn
                @table?.find('.summary-img').click(@showColumnSummary).dropdown()
            @drawn = true

        refresh: =>
            @table?.fnDestroy()
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

            @query.on "change:constraints", @refresh
            @query.on "change:joins", @refresh

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
        getRowData: (src, params, callback) =>
            echo = intermine.utils.getParameter(params, "sEcho")
            start = intermine.utils.getParameter(params, "iDisplayStart")
            size = intermine.utils.getParameter(params, "iDisplayLength")
            end = start + size
            isOutOfRange = false

            @adjustSortOrder(params)

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

            if isStale or isOutOfRange
                page = @getPage start, size
                @overlayTable()

                req = @query.table page, (rows, resultSet) =>
                    @addRowsToCache page, resultSet
                    @cache.freshness = freshness
                    @serveResultsFromCache echo, start, size, callback
                req.fail @showError
                req.always @removeOverlay
            else
                @serveResultsFromCache echo, start, size, callback

        overlayTable: =>
            return unless @table and @drawn
            elOffset = @$el.offset()
            tableOffset = @table.offset()
            @overlay = jQuery @make "div", class: "im-table-overlay discrete"
            @overlay.css
                top: elOffset.top
                left: elOffset.left
                width: @table.outerWidth(true)
                height: (tableOffset.top - elOffset.top) + @table.outerHeight()
            @overlay.append @make "h1", {}, "Requesting data..."
            @overlay.find("h1").css
                top: (@table.height() / 2) + "px"
                left: (@table.width() / 4) + "px"
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

        updateSummary: (result) ->
            summary = @$ '.im-table-summary'
            console.log result
            html    = COUNT_HTML
                count: intermine.utils.numToString(result.iTotalRecords, ",", 3)
                roots: intermine.utils.pluralise(@query.root)
            summary.html html

        ##
        ## Retrieve the results from the results cache.
        ##
        ## @param echo The results table request control.
        ## @param start The index of the first result desired.
        ## @param size The page size
        ##
        serveResultsFromCache: (echo, start, size, callback) ->
            base = @query.service.root.replace /\/service\/?$/, ""
            result = jQuery.extend true, {}, @cache.lastResult
            result.sEcho = echo
            # Splice off the undesired sections.
            result.results.splice(0, start - @cache.lowerBound)
            result.results.splice(size, result.results.length)

            @updateSummary result

            fields = (v.replace(/^.*\./, "") for v in result.views)
            result.aaData = result.results.map (row) =>
                (row).map (cell, idx) =>
                    cv = if cell.id
                        field = fields[idx]
                        imo = @itemModels[cell.id] or= (new intermine.model.IMObject(@query, cell, field, base))
                        imo.merge cell, field
                        new intermine.results.table.Cell(
                            model: imo
                            field: field
                            query: @query
                        )
                    else
                        new intermine.results.table.NullCell()

                    cv.render().el

            callback(result)

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
                <div class="progress progress-striped active progress-info">
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

        onSetupSuccess: (telem) -> (result) =>
            jQuery(telem).empty()
            dtopts = jQuery.extend true, {}, TABLE_INIT_PARAMS,
                fnServerData: @getRowData
                fnDrawCallback: @onDraw
                aoColumns: (@makeCol(result) view, index for view, index in @query.views)

            @table = jQuery(telem).dataTable dtopts

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













            

            






            









