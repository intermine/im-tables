do ->

    NUMERIC_TYPES = ["int", "Integer", "double", "Double", "float", "Float"]

    errorTempl = _.template """
      <div class="alert alert-error">
        <h2>Oops!</h2>
        <p><i><%- error %></i></p>
        <p><%= body %></p>
        <a class="btn btn-primary pull-right" href="mailto://<%- mailto %>">Email the help desk</a>
        <button class="btn btn-error">Show query</button>
        <p class="query-xml" style="display:none" class="well">
          <textarea><%= query %></textarea>
        <p>
      </div>
    """

    renderError = (query, err, time) =>
      time ?= new Date()
      console.error(err, err?.stack)
      if /TypeError/.test(String(err))
        errConf = intermine.options.ClientApplicationError
        message = errConf.Heading
      else
        errConf = intermine.options.ServerApplicationError
        message = (err?.message ? errConf.Heading)

      mailto = query.service.help + "?" + $.param {
          subject: "Error running embedded table query"
          body: """
              We encountered an error running a query from an
              embedded result table.
              
              page:       #{ window.location }
              service:    #{ query.service.root }
              error:      #{ err }
              date-stamp: #{ time }

              -------------------------------
              IMJS:       #{ intermine.imjs.VERSION }
              -------------------------------
              IMTABLES:   #{ intermine.imtables.VERSION }
              -------------------------------
              QUERY:      #{ query.toXML() }
              -------------------------------
              STACK:      #{ err?.stack }
          """
      }, true
      mailto = mailto.replace(/\+/g, '%20') # stupid jquery 'wontfix' indeed. grumble

      notice = $ errorTempl
        error: message
        body: errConf.Body
        query: query.toXML()
        mailto: mailto

      notice.find('button').click -> notice.find('.query-xml').slideToggle()

      return notice

    class RowModel extends Backbone.Model

    class NestedTableModel extends Backbone.Model

      initialize: ->
        {query, column} = @toJSON()
        query.on 'expand:subtables', (path) =>
          if path.toString() is column.toString()
            @trigger 'expand'

        query.on 'collapse:subtables', (path) =>
          if path.toString() is column.toString()
            @trigger 'collapse'

        column.getDisplayName().then (name) =>
          @set columnName: name
        query.model.makePath(column.getType()).getDisplayName().then (name) =>
          @set columnTypeName: name

        for evt in ['expanded', 'collapsed'] then do (evt) =>
          @on evt, => @get('query').trigger "subtable:#{ evt }", @get('column')

    class CellModel extends Backbone.Model

      initialize: ->
          @get('column').getDisplayName().then (name) => @set columnName: name
          type = @get('cell').get('obj:type')
          @get('query').model.makePath(type).getDisplayName().then (name) ->
            @set typeName: name

    class Page
        constructor: (@start, @size) ->
        end: -> @start + @size
        all: -> !@size
        toString: () -> "Page(#{ @start}, #{ @size })"

    # Inner class that only knows how to render results, but not where they come from.
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

        # TODO - check instantiation
        initialize: (@query, @blacklistedFormatters, @columnHeaders, @rows) ->
          @minimisedCols = {}
          @query.on 'columnvis:toggle', (view) =>
            @minimisedCols[view] = not @minimisedCols[view]
            @query.trigger 'change:minimisedCols', _.extend({}, @minimisedCols), view
            @fill()

          @listenTo @columnHeaders, 'reset add remove', @renderHeaders
          @listenTo @blacklistedFormatters, 'reset add remove', @fill
          @listenTo @rows, 'reset add remove', @fill

        render: ->
          @$el.empty()
          @$el.append document.createElement 'thead'
          @renderHeaders()
          @$el.append document.createElement 'tbody'
          @fill()

        fill: ->
          # Clean up old children.
          previousCells = (@currentCells || []).slice()
          for cell in previousCells
            cell.remove()
          @currentCells = []
          return @handleEmptyTable() if @rows.size() < 1

          docfrag = document.createDocumentFragment()

          @rows.each (row) => @appendRow docfrag, row

          # Careful - there might be subtables out there - be specific.
          @$el.children('tbody').html docfrag

          @query.trigger "table:filled"

        handleEmptyTable: () ->
          @$("tbody > tr").remove()
          apology = _.template intermine.snippets.table.NoResults @query
          @$el.append apology
          @$el.find('.btn-primary').click => @query.trigger 'undo'

        minimisedColumnPlaceholder: _.template """
            <td class="im-minimised-col" style="width:<%= width %>px">&hellip;</td>
        """

        renderCell: (cell) =>
          base = @query.service.root.replace /\/service\/?$/, ""
          if cell instanceof NestedTableModel
            node = @query.getPathInfo obj.column
            return new intermine.results.table.SubTable
              model: cell
              cellify: @renderCell
              canUseFormatter: (f) => @canUseFormatter
              mainTable: @
          else
            return new intermine.results.table.Cell(model: cell)

        canUseFormatter: (formatter) ->
          formatter? and (not @blacklistedFormatters.any (f) -> f.get('formatter') is formatter)

        # tbody :: HTMLElement, row :: RowModel
        appendRow: (tbody, row) =>
          tr = document.createElement 'tr'
          tbody.appendChild tr
          minWidth = 10
          minimised = (k for k, v of @minimisedCols when v)
          replacer_of = {}
          processed = {}
          @columnHeaders.each (col) ->
            for r in (rs = col.get('replaces'))
              replacer_of[r] = col

          # Render models into views
          cellViews = (@renderCell cell for cell in row.get('cells'))

          # cell :: Cell | SubTable, i :: int
          for cell, i in cellViews then do (cell, i) =>
            cellPath = cell.path
            return if processed[cellPath]
            processed[cellPath] = true
            {replaces, formatter, path} = (replacer_of[cellPath]?.toJSON() ? {})
            if replaces?.length > 1
              # Only accept if it is the right type, since formatters expect a type.
              return unless path.equals(cellPath.getParent())
              if formatter?.merge?
                for c in cellViews when _.any(replaces, (x) -> x.equals c.path)
                  formatter.merge(cell.model.get('cell'), c.model.get('cell'))

              processed[r] = true for r in replaces

            cell.formatter = formatter if formatter?

            if @minimisedCols[ cellPath ] or (path and @minimisedCols[path])
              $(tr).append @minimisedColumnPlaceholder width: minWidth
            else
              cell.render()
              tr.appendChild cell.el

        # Add headers to the table
        renderHeaders: ->
          docfrag = document.createDocumentFragment()
          tr = document.createElement 'tr'
          docfrag.appendChild tr

          @columnHeaders.each (ch) => @renderHeader ch, tr
                  
          # children selector because we only want to go down 1 layer.
          @$el.children('thead').html docfrag

        # Render a single header to the headers
        renderHeader: (model, tr) ->
          {ColumnHeader} = intermine.query.results
          header = new ColumnHeader {model, @query, @blacklistedFormatters}
          header.render().$el.appendTo tr

        handleError: (err, time) =>
          notice = renderError @query, err, time
          @$el.append notice

    class PageSizer extends Backbone.View

        tagName: 'form'
        className: "im-page-sizer form-horizontal"
        sizes: [[10], [25], [50], [100], [250]] # [0, 'All']]

        initialize: ->
          if size = @model.get('size')
            unless _.include (s[0] for s in @sizes), size
              @sizes = [[size, size]].concat @sizes # assign, don't mutate
          @listenTo @model, 'change:size', => @$('select').val @model.get 'size'

        events: { 'change select': 'changePageSize' }

        changePageSize: (evt) ->
          size = parseInt($(evt.target).val(), 10)
          @model.set size: size

        render: ->
          frag = $ document.createDocumentFragment()
          size = @model.get 'size'
          frag.append """
            <label>
              <span class="im-only-widescreen">Rows per page:</span>
              <select class="span" title="Rows per page"></select>
            </label>
          """
          select = @$('select')
          for [value, label] in @sizes
            select.append @make 'option', {value, selected: value is size}, (label or value)

          @$el.html frag

          this

    class Table extends Backbone.View

        className: "im-table-container"

        events: # TODO - move into child components
            'submit .im-page-form': 'pageFormSubmit'
            'click .im-pagination-button': 'pageButtonClick'

        onDraw: =>
            @query.trigger("start:list-creation") if @__selecting
            @drawn = true

        refresh: =>
            @query.__changed = (@query.__changed or 0) + 1
            @table?.remove()
            @drawn = false
            @render()

        remove: ->
          @table?.remove()
          super()

        getPage: ->
          {start, size} = @model.toJSON()
          return new Page start, size

        # @param query The query this view is bound to.
        # @param selector Where to put this table.
        initialize: (@query, @columnHeaders, {start, size}) ->
          @itemModels = {}
          @_pipe_factor = 10
          @__selecting = false
          @visibleViews = @query.views.slice()

          # columnHeaders contains the header information.
          @columnHeaders ?= new Backbone.Collection
          # rows contains the current rows in the table
          @rows = new Backbone.Collection
          # Formatters we are not allowed to use.
          @blacklistedFormatters = new Backbone.Collection
          # stores state, start, size, cache, lowerBound, upperBound, count
          @model = new Backbone.Model
            freshness: @calculateFreshness()
            state: 'FETCHING' # FETCHING, SUCCESS or ERROR
            start: (start ? 0)
            size: (size ? intermine.options.DefaultPageSize)
            count: null,
            lowerBound: null
            upperBound: null
            cache: null
            error: null

          @listenTo @model, 'change:state', @render
          @listenTo @model, 'change:size', @handlePageSizeSelection
          @listenTo @model, 'change:start change:size change:count', @updateSummary
          @listenTo @model, 'change:freshness', => @model.set cache: null
          @listenTo @model, 'change:freshness change:start change:size', @fillRows
          @listenTo @model, 'change:cache', => @buildColumnHeaders()
          @listenTo @blacklistedFormatters, 'reset add remove', => @buildColumnHeaders()
          @listenTo @model, 'change:cache', => # Ensure model consistency
            @model.set(lowerBound: null, upperBound: null) unless @model.get('cache')?
          @listenTo @model, 'change:count', => # Previously propagated.
            @query.trigger 'count:is', @data.get 'count'
          @listenTo @model, 'change:error', =>
            err = @model.get 'error'
            @model.set(state: 'ERROR') if err?

          @query.on 'change:sortorder change:views change:constraints', =>
            @model.set freshness: @calculateFreshness()
          @query.on "start:list-creation", => @__selecting = true
          @query.on "stop:list-creation", => @__selecting = false

          @query.on "table:filled", @onDraw

          @query.on 'page:forwards', => @goForward 1
          @query.on 'page:backwards', => @goBack 1
          @query.on "add-filter-dialogue:please", () =>
            dialogue = new intermine.filters.NewFilterDialogue(@query)
            @$el.append dialogue.el
            dialogue.render().openDialogue()

          @query.on "download-menu:open", =>
            dialogue = new intermine.query.export.ExportDialogue @query
            @$el.append dialogue.render().el
            dialogue.show()

          # Always good to know the API version.
          @query.service.fetchVersion (error, version) => @model.set {error, version}
          @query.count (error, count) => @model.set {error, count}

          @fillRows().then (-> console.debug 'initial data loaded'), (error) => @model.set {error}
          console.debug 'initialised table'

        pageSizeFeasibilityThreshold: 250

        canUseFormatter: (formatter) ->
          formatter? and (not @blacklistedFormatters.any (f) -> f.get('formatter') is formatter)

        buildColumnHeaders: -> @query.service.get("/classkeys").then ({classes}) =>
          q = @query
          return unless @model.get('cache')?.length
          [row] = @model.get 'cache' # need at least one example row - any will do.
          classKeys = classes
          replacedBy = {}
          {longestCommonPrefix, getReplacedTest} = intermine.utils

          # Create the columns
          cols = for cell in row
            path = q.getPathInfo cell.column
            replaces = if cell.view? # subtable of this cell.
              commonPrefix = longestCommonPrefix cell.view
              path = q.getPathInfo commonPrefix
              replaces = (q.getPathInfo(v) for v in cell.view)
            else
              []
            {path, replaces}

          # Build the replacement information.
          for col in cols when col.path.isAttribute() and intermine.results.shouldFormat col.path
            p = col.path
            formatter = intermine.results.getFormatter p
            
            # Check to see if we should apply this formatter.
            if @canUseFormatter formatter
              col.isFormatted = true
              col.formatter = formatter
              for r in (formatter.replaces ? [])
                subPath = "#{ p.getParent() }.#{ r }"
                replacedBy[subPath] ?= col
                col.replaces.push q.getPathInfo subPath if subPath in q.views

          isKeyField = (col) ->
            return false unless col.path.isAttribute()
            pType = col.path.getParent().getType().name
            fName = col.path.end.name
            return "#{pType}.#{fName}" in (classKeys?[pType] ? [])

          explicitReplacements = {}
          for col in cols
            for r in col.replaces
              explicitReplacements[r] = col

          isReplaced = getReplacedTest replacedBy, explicitReplacements

          newHeaders = for col in cols when not isReplaced col
            if col.isFormatted
              col.replaces.push col.path unless col.path in col.replaces
              col.path = col.path.getParent() if (isKeyField(col) or col.replaces.length > 1)
            col

          @columnHeaders.reset newHeaders

        # Check if the given size could be considered problematic
        #
        # A size if problematic if it is above the preset threshold, or if it 
        # is a request for all results, and we know that the count is large.
        # @param size The size to assess.
        aboveSizeThreshold: (size) ->
          if size and size >= @pageSizeFeasibilityThreshold
            return true
          if not size # falsy values null, 0 and '' are treated as all
            total = @model.get('count')
            return total >= @pageSizeFeasibilityThreshold
          return false

        # If the new page size is potentially problematic, then check with the user
        # first, rolling back if they see sense. Otherwise, change the page size
        # without user interaction.
        # @param size the requested page size.
        handlePageSizeSelection: (model, size) =>
          oldSize = model.previous 'size'
          if @aboveSizeThreshold size
            $really = $ intermine.snippets.table.LargeTableDisuader
            $really.find('.btn-primary').click -> model.set {size}
            $really.find('.btn').click -> $really.modal('hide')
            $really.find('.im-alternative-action').click (e) =>
                @query.trigger($(e.target).data 'event') if $(e.target).data('event')
                @model.set size: oldSize
            $really.on 'hidden', -> $really.remove()
            $really.appendTo(@el).modal().modal('show')

        # Take a bad response and present the error somewhere visible to the user.
        # @param resp An ajax response.
        showError: (resp) =>
            try
                data = JSON.parse(resp.responseText)
                @table?.handleError(data.error, data.executionTime)
            catch err
                @table?.handleError("Internal error", new Date().toString())

        calculateFreshness: -> @query.toXML()

        ##
        ## Filling the rows is a two step process - first we check the row cache to see
        ## if we already have these rows, or update it if not. Only then do we go about
        ## updating the rows collection.
        ## 
        ## Function for buffering data for a request. Each request fetches a page of
        ## pipe_factor * size, and if subsequent requests request data within this range, then
        ##
        ## @param src URL passed from DataTables. Ignored.
        ## @param param list of {name: x, value: y} objects passed from DataTables
        ## @param callback fn of signature: resultSet -> ().
        ##
        ##
        fillRows: ->
          console.debug 'filling rows'
          success = => @model.set state: 'SUCCESS'
          error = (e) => @model.set state: 'ERROR', error: (e ? new Error('unknown error'))
          @updateCache().then(@fillRowsFromCache).then success, error

        updateCache: ->
          console.debug 'updating cache'
          {version, cache, lowerBound, upperBound, start, size} = @model.toJSON()
          end = start + size

          # if stale, cache will be null
          isStale = not cache?

          ## We need new data if the range of this request goes beyond that of the 
          ## cached values, or if all results are selected.
          uncached = (lowerBound < 0) or (start < lowerBound) or (end > upperBound) or (size <= 0)

          # Return a promise to update the cache
          updatingCache = if isStale or uncached
            page = @getRequestPage start, size
            console.debug 'requesting', page

            @overlayTable()
            fetching = @query.tableRows {start: page.start, size: page.size}
            # Always remove the overlay
            fetching.then @removeOverlay, @removeOverlay
            fetching.then (r) => @addRowsToCache page, r
          else
            console.debug 'cache does not need updating'
            jQuery.Deferred(-> @resolve()).promise()

        getRowData: (start, size) => # params, callback) =>

        overlayTable: =>
            return unless @table and @drawn
            elOffset = @$el.offset()
            tableOffset = @table.$el.offset()
            jQuery('.im-table-overlay').remove()
            @overlay = jQuery @make "div",
              class: "im-table-overlay discrete " + intermine.options.StylePrefix
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
        getRequestPage: ->
          {start, size, cache, lowerBound, upperBound} = @model.toJSON()
          page = new Page(start, size)
          unless cache
            ## Can ignore the cache
            page.size *= @_pipe_factor
            return page

          # When paging backwards - extend page towards 0.
          if start < lowerBound
              page.start = Math.max 0, start - (size * @_pipe_factor)

          if size > 0
              page.size *= @_pipe_factor
          else
              page.size = '' # understood by server as all.

          # Don't permit gaps, if the query itself conforms with the cache.
          if page.size && (page.end() < lowerBound)
            if (lowerBound - page.end()) > (page.size * @_pipe_factor)
              @model.unset 'cache'
              page.size *= 2
              return page
            else
              page.size = lowerBound - page.start

          if upperBound < page.start
            if (page.start - @cache.upperBound) > (page.size * 10)
              @model.unset 'cache'
              page.size *= 2
              page.start = Math.max(0, page.start - (size * @_pipe_factor))
              return page
            if page.size
              page.size += page.start - @cache.upperBound
            # Extend towards cache limit
            page.start = upperBound

          return page

        ##
        ## Update the cache with the retrieved results. If there is an overlap 
        ## between the returned results and what is already held in cache, prefer the newer 
        ## results.
        ##
        ## @param page The page these results were requested with.
        ## @param rows The rows returned from the server.
        ##
        addRowsToCache: (page, rows) ->
          # {cache :: [], lowerBound :: int, upperBound :: int}
          {cache, lowerBound, upperBound} = @model.toJSON()
          if cache? # may not exist yet.
            cache = cache.slice()
            # Add rows we don't have to the front
            if page.start < lowerBound
                cache = rows.concat cache.slice page.end() - lowerBound
            # Add rows we don't have to the end
            if upperBound < page.end() or page.all()
                cache = cache.slice(0, (page.start - lowerBound)).concat(rows)

            lowerBound = Math.min lowerBound, page.start
            upperBound = lowerBound + merged.length
          else
            cache = rows.slice()
            lowerBound = page.start
            upperBound = page.end()

          @model.set {cache, lowerBound, upperBound}

        updateSummary: ->
          {start, size, count} = @model.toJSON()
          summary = @$ '.im-table-summary'
          summary.html intermine.snippets.table.CountSummary
            first: start + 1
            last: if (size is 0) then 0 else Math.min(start + size, count)
            count: intermine.utils.numToString(count, ",", 3)
            roots: "rows"

        
        makeCellModel: (obj) =>
          base = @query.service.root.replace /\/service\/?$/, ""
          cm = if _.has(obj, 'rows')
            node = @query.getPathInfo obj.column
            _.extend obj,
              query: @query
              node: node
              column: node
              rows: (r.map(@makeCellModel) for r in obj.rows)
            new NestedTableModel obj
          else
            column = @query.getPathInfo(obj.column)
            node = column.getParent()
            field = obj.column.replace(/^.*\./, '')
            model = if obj.id?
              @itemModels[obj.id] or= (new intermine.model.IMObject(obj, @query, field, base))
            else if not obj.class?
              type = node.getParent().name
              new intermine.model.NullObject {}, {@query, field, type}
            else # FastPathObjects don't have ids, and cannot be in lists.
              new intermine.model.FPObject({}, {@query, obj, field})
            model.merge obj, field
            new CellModel _.extend
              query: @query
              cell: model
              node: node
              column: column
              field: field
              value: obj.value
          return cm

        ##
        ## Populate the rows collection with the current rows from cache.
        ## This requires that the cache has been populated, so should only
        ## be called from `::fillRows`
        ##
        ## @param echo The results table request control.
        ## @param start The index of the first result desired.
        ## @param size The page size
        ##
        fillRowsFromCache: =>
          console.debug 'filling rows from cache'
          {cache, lowerBound, start, size} = @model.toJSON()
          if not cache?
            return console.error 'Cache is not filled'
          base = @query.service.root.replace /\/service\/?$/, ""
          rows = cache.slice()
          # Splice off the undesired sections.
          rows.splice(0, start - lowerBound)
          rows.splice(size, rows.length) if (size > 0)

          # TODO - make sure cells know their node...

          fields = ([@query.getPathInfo(v).getParent(), v.replace(/^.*\./, "")] for v in @query.views)

          @rows.reset rows.map (row) =>
            new RowModel cells: row.map (cell, idx) => @makeCellModel cell
          console.debug 'rows filled', @rows.size()

        tableAttrs:
            class: "table table-striped table-bordered"
            width: "100%"
            cellpadding: 0
            border: 0
            cellspacing: 0

        renderFetching: ->
          """
            <h2>Building table</h2>
            <div class="progress progress-striped active progress-info">
                <div class="bar" style="width: 100%"></div>
            </div>
          """

        renderError: -> renderError @query, @model.get('error')

        renderTable: ->
          frag = document.createDocumentFragment()
          $widgets = $('<div>').appendTo frag
          for component in intermine.options.TableWidgets when "place#{ component }" of @
            method = "place#{ component }"
            @[ method ]( $widgets )
          $widgets.append """<div style="clear:both"></div>"""

          tel = @make 'table', @tableAttrs
          frag.appendChild tel

          @table = new ResultsTable @query, @blacklistedFormatters, @columnHeaders, @rows
          @table.setElement tel
          @table.render()

          return frag

        render: ->
          @table?.remove()
          state = @model.get('state')

          if state is 'FETCHING'
            console.debug 'state is fetching'
            @$el.html @renderFetching()
          else if state is 'ERROR'
            console.debug 'state is error'
            @$el.html @renderError()
          else
            console.debug 'state is success'
            @$el.html @renderTable()

        horizontalScroller: """
          <div class="scroll-bar-wrap well">
            <div class="scroll-bar-containment">
              <div class="scroll-bar alert-info alert"></div>
            </div>
          </div>
        """

        placePagination: ($widgets) ->
          $pagination = $(intermine.snippets.table.Pagination).appendTo($widgets)
          $pagination.find('li').tooltip(placement: "top")
          currentPageButton = $pagination.find(".im-current-page a").click =>
            size = @model.get 'size'
            total = @model.get 'count'
            return if size >= total
            currentPageButton.hide()
            $pagination.find('form').show()

        placePageSizer: ($widgets) ->
            pageSizer = new PageSizer(model: @model)
            pageSizer.render().$el.appendTo $widgets

        placeTableSummary: ($widgets) ->
            $widgets.append """
                <span class="im-table-summary"></div>
            """

        getCurrentPageSize: -> @model.get 'size'

        getCurrentPage: () ->
          {start, size} = @model.toJSON()
          if size then Math.floor(start / size) else 0

        getMaxPage: () ->
          {count, size} = @model.toJSON()
          correction = if count % size is 0 then -1 else 0
          Math.floor(count / size) + correction

        goTo: (start) -> @model.set start: start

        goToPage: (page) -> @model.set start: (page * @model.get('size'))

        goBack: (pages) ->
          {start, size} = @model.toJSON()
          @goTo Math.max 0, start - (pages * size)

        goForward: (pages) ->
          {start, size} = @model.get 'start'
          @goTo Math.min @getMaxPage() * size, start + (pages * size)

        pageButtonClick: (e) ->
          $elem = $(e.target)
          unless $elem.parent().is('.active') # Here active means "where we are"
            switch $elem.data("goto")
              when "start"        then @goTo 0
              when "prev"         then @goBack 1
              when "fast-rewind"  then @goBack 5
              when "next"         then @goForward 1
              when "fast-forward" then @goForward 5
              when "end"          then @goToPage @getMaxPage()

        pageFormSubmit: (e) ->
            e.stopPropagation()
            e.preventDefault()
            pageForm = @$('.im-page-form')
            centre = @$('.im-current-page')
            inp = pageForm.find('input')
            if inp.size()
                destination = inp.val().replace(/\s*/g, "")
            	if destination.match /^\d+$/
                    newSelectorVal = Math.min @getMaxPage(), Math.max(parseInt(destination) - 1, 0)
                    @table.goToPage newSelectorVal
                    centre.find('a').show()
                    pageForm.hide()
            	else
                    pageForm.find('.control-group').addClass 'error'
                    inp.val ''
                    inp.attr placeholder: "1 .. #{ @getMaxPage() + 1 }"

    scope "intermine.query.results", {Table}

