do ->

    _CELL_HTML = _.template """
      <input class="list-chooser" type="checkbox"
        <% if (checked) { %> checked <% } %>
        <% if (disabled) { %> disabled <% } %>
        style="display: <%= display %>"
      >
      <a class="im-cell-link" target="<%= target %>" href="<%= url %>">
        <% if (isForeign) { %>
          <% if (icon) { %>
            <img src="<%= icon %>" class="im-external-link"></img>
          <% } else { %>
            <i class="icon-globe"></i>
          <% } %>
        <% } %>
        <% if (value == null) { %>
          <span class="null-value">&nbsp;</span>
        <% } else { %>
          <span class="im-displayed-value">
            <%= value %>
          </span>
        <% } %>
      </a>
      <% if (rawValue != null && field == 'url' && rawValue != url) { %>
          <a class="im-cell-link external" href="<%= rawValue %>">
            <i class="icon-globe"></i>
            link
          </a>
      <% } %>
    """

    CELL_HTML = (data) ->
      {url, host} = data
      data.isForeign = (url and not url.match host)
      data.target = if data.isForeign then '_blank' else ''
      _CELL_HTML data

    class SubTable extends Backbone.View
        tagName: "td"
        className: "im-result-subtable"

        initialize: (@options = {}) ->
            @query = @options.query
            @cellify = @options.cellify
            @path = @options.node
            subtable = @options.subtable
            @rows = subtable.rows
            @view = subtable.view
            @column = @query.getPathInfo(subtable.column)
            @query.on 'expand:subtables', (path) =>
              if path.toString() is @column.toString()
                @renderTable().slideDown()
            @query.on 'collapse:subtables', (path) =>
              if path.toString() is @column.toString()
                @$('.im-subtable').slideUp()

        getSummaryText: () ->
          def = jQuery.Deferred()

          if @column.isCollection()
              def.resolve """#{ @rows.length } #{ @column.getType().name }s"""
          else
              # Single collapsed reference.
              if @rows.length is 0
                  # find the outer join:
                  level = if @query.isOuterJoined(@view[0])
                      @query.getPathInfo(@query.getOuterJoin(@view[0]))
                  else
                      @column
                  def.resolve """
                    <span class="im-no-value">No #{ level.getType().name }</span>
                  """
              else
                  def.resolve """#{@rows[0][0].value} (#{@rows[0][1 ..].map((c) -> c.value).join(', ')})"""
          def.promise()

        getEffectiveView: ->
          # TODO: refactor the common code between this and Table#getEffectiveView
          {getReplacedTest, longestCommonPrefix} = intermine.utils
          {shouldFormat, getFormatter} = intermine.results
          row = @rows[0] # use first row as pattern for all of them
          replacedBy = {}
          explicitReplacements = {}

          columns = for cell in row
            [path, replaces] = if cell.view? # subtable of this cell
              commonPrefix = longestCommonPrefix cell.view
              path = @query.getPathInfo commonPrefix
              [path, (@query.getPathInfo sv for sv in cell.view)]
            else
              path = @query.getPathInfo cell.column
              [path, [path]]
            {path, replaces}

          for c in columns when c.path.isAttribute() and shouldFormat c.path
            parent = c.path.getParent()
            replacedBy[parent] ?= c
            formatter = getFormatter c.path
            unless formatter in @options.blacklistedFormatters
              c.isFormatted = true
              c.formatter = formatter
              for fieldExpr in (formatter.replaces ? [])
                subPath = @query.getPathInfo "#{ parent }.#{ fieldExpr }"
                replacedBy[subPath] ?= c
                c.replaces.push subPath
            explicitReplacements[r] = c for r in c.replaces

          isReplaced = getReplacedTest replacedBy, explicitReplacements

          view = []
          for col in columns when not isReplaced col
            if col.isFormatted
              col.path = col.path.getParent()
            view.push col

          return view

        renderHead: (headers, columns) ->
          # Prefer column to view as it is reliable.
          tableNamePromise = @column.getDisplayName()
          for c in columns then do (c) =>
            th = $ """<th>
                <i class="#{intermine.css.headerIconRemove}"></i>
                <span></span>
            </th>"""
            th.find('i').click (e) => @query.removeFromSelect c.replaces
            $.when(tableNamePromise, c.path.getDisplayName()).then (tableName, colName) ->
              text = if colName.match(tableName)
                  colName.replace(tableName, '').replace(/^\s*>?\s*/, '')
              else
                  colName.replace(/^[^>]*\s*>\s*/, '')
              span = th.find('span').text text

            headers.append th

        appendRow: (columns, row, tbody) =>
          tbody ?= @$ '.im-subtable tbody'
          tr = $ '<tr>'
          w = @$el.width() / @view.length
          processed = {}
          replacedBy = {}
          for c in columns
            for r in c.replaces
              replacedBy[r] = c

          cells = row.map @cellify

          for cell in cells then do (tr, cell) =>
            return if processed[cell.path]
            processed[cell.path] = true
            {replaces, formatter, path} = replacedBy[cell.path] ? {replaces: []}
            if replaces.length > 1
              # Only accept if it is the right type - otherwise break (aka return)
              # this is required because formatters need to be based on a model of the
              # right type, and the merge method is not guaranteed to be associative.
              return unless path.equals(cell.path.getParent())
              if formatter?.merge?
                for otherC in row when _.any(replaces, (repl) -> repl.equals otherC.path)
                  formatter.merge(cell.model, otherC.model)
            processed[r] = true for r in replaces
            cell.formatter = formatter if formatter?

            tr.append cell.el
            cell.render().setWidth w

          tr.appendTo tbody
          null

        renderTable: ($table) ->
          $table ?= @$ '.im-subtable'
          return $table if @tableRendered
          colRoot = @column.getType().name
          colStr = @column.toString()
          if @rows.length > 0
            columns = @getEffectiveView()
            @renderHead $table.find('thead tr'), columns
            tbody = $table.find 'tbody'
            docfrag = document.createDocumentFragment()

            if @column.isCollection()
                @appendRow(columns, row, docfrag) for row in @rows
            else
                @appendRow(columns, @rows[0], docfrag) # Odd hack to fix multiple repeated rows.
            tbody.html docfrag
          @tableRendered = true
          $table

        events:
          'click .im-subtable-summary': 'toggleTable'

        toggleTable: (e) ->
          e?.stopPropagation()
          $table = @$ '.im-subtable'
          evt = if $table.is ':visible'
            'subtable:collapsed'
          else
            @renderTable $table
            'subtable:expanded'
          $table.slideToggle()
          @query.trigger evt, @column

        render: () ->
            icon = if @rows.length > 0
              """<i class="#{ intermine.icons.Table }"></i>"""
            else
              '<i class=icon-non-existent></i>'

            summary = $ """
              <span class="im-subtable-summary">
                #{ icon }&nbsp;
              </span>
            """
            summary.appendTo @$el
            @getSummaryText().done (content) -> summary.append content

            @$el.append """
              <table class="im-subtable table table-condensed table-striped">
                <thead><tr></tr></thead>
                <tbody></tbody>
              </table>
            """

            if intermine.options.SubtableInitialState is 'open' or @options.mainTable.SubtableInitialState is 'open'
              @toggleTable()

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

        formatter: (model) ->
          if model.get(@options.field)?
            model.escape @options.field
          else
            """<span class="null-value">&nbsp;</span>"""

        initialize: (@options = {}) ->
          @model.on 'change', @selectingStateChange, @
          @model.on 'change', @updateValue, @

          @listenToQuery @options.query

          field = @options.field
          path = @path = @options.node.append field
          @$el.addClass 'im-type-' + path.getType().toLowerCase()

        remove: ->
          @model.off 'change', @selectingStateChange
          @model.off 'change', @updateValue
          @popover?.remove()
          super

        events: ->
          'shown': => @cellPreview?.reposition()
          'show': (e) =>
            @options.query.trigger 'showing:preview', @el
            e?.preventDefault() if @model.get 'is:selecting'
          'hide': (e) => @model.cachedPopover?.detach()
          'click': 'activateChooser'
          'click a.im-cell-link': (e) =>
            # Prevent bootstrap from closing dropdowns, etc.
            e?.stopPropagation()
            # Allow the table to handle this event, if
            # it chooses to.
            e.object = @model # one arg good, more args bad.
            @options.query.trigger 'object:view', e

        reportClick: -> @model.trigger 'click', @model

        listenToQuery: (q) ->
          q.on "start:list-creation", =>
            @model.set 'is:selecting': true
          q.on "stop:list-creation", =>
            @model.set 'is:selecting': false, 'is:selected': false
          q.on 'showing:preview', (el) => # Close ours if another is being opened.
            @cellPreview?.hide() unless el is @el

          q.on "start:highlight:node", (node) =>
            if @options.node?.toPathString() is node.toPathString()
              @$el.addClass "im-highlight"
          q.on "stop:highlight", => @$el.removeClass "im-highlight"

          q.on "replaced:by", (replacement) => @listenToQuery replacement
      
        getPopoverContent: =>
          return @model.cachedPopover if @model.cachedPopover?

          type = @model.get 'obj:type'
          id = @model.get 'id'

          popover = @popover = new intermine.table.cell.Preview
            service: @options.query.service
            schema: @options.query.model
            model: {type, id}

          content = popover.$el

          popover.on 'rendered', => @cellPreview.reposition()
          popover.render()

          @model.cachedPopover = content

        getPopoverPlacement: (popover) =>
          table = @$el.closest ".im-table-container"
          {left} = @$el.offset()

          limits = table.offset()
          _.extend limits,
            right: limits.left + table.width()
            bottom: limits.top + table.height()

          w = @$el.width()
          h = @$el.height()
          elPos = @$el.offset()

          pw = $(popover).outerWidth()
          ph = $(popover)[0].offsetHeight

          fitsOnRight = left + w + pw <= limits.right
          fitsOnLeft = limits.left <= left - pw

          if fitsOnLeft
            return 'left'
          if fitsOnRight
            return 'right'
          else
            return 'top'

        setupPreviewOverlay: ->
          options =
            container: @el
            containment: '.im-query-results'
            html: true
            title: @model.get 'obj:type'
            trigger: intermine.options.CellPreviewTrigger
            delay: {show: 250, hide: 250} # Slight delays to prevent jumpiness.
            classes: 'im-cell-preview'
            content: @getPopoverContent
            placement: @getPopoverPlacement

          @cellPreview = new intermine.bootstrap.DynamicPopover @el, options

        updateValue: -> _.defer =>
          @$('.im-displayed-value').html @formatter(@model)

        getInputState: ->
          {selected, selectable, selecting} = @model.selectionState()
          checked = selected
          disabled = not selectable
          display = if selecting and selectable then 'inline' else 'none'
          {checked, disabled, display}

        selectingStateChange: ->
          {checked, disabled, display} = @getInputState()
          @$el.toggleClass "active", checked
          @$('input').attr({checked, disabled}).css {display}

        getData: ->
          {IndicateOffHostLinks, ExternalLinkIcons} = intermine.options
          field = @options.field
          data =
            value: @formatter(@model)
            rawValue: @model.get(field)
            field: field
            url: @model.get('service:url')
            host: if IndicateOffHostLinks then window.location.host else /.*/
            icon: null
          _.extend data, @getInputState()

          unless /^http/.test(data.url)
            data.url = @model.get('service:base') + data.url

          for domain, url of ExternalLinkIcons when data.url.match domain
            data.icon ?= url
          data

        render: ->
          data = @getData()
          @$el.html CELL_HTML data
          @$el.addClass 'active' if data.checked
          @setupPreviewOverlay() if @model.get('id')
          this

        setWidth: (w) -> # no-op. Was used, but can be removed when all callers are.
          this

        activateChooser: ->
          @reportClick()
          {selected, selectable, selecting} = @model.selectionState()
          if selectable and selecting
            @model.set 'is:selected': not selected

    class NullCell extends Cell
        setupPreviewOverlay: ->

        initialize: (@options = {}) ->
          @model = new intermine.model.NullObject()
          super()

    scope "intermine.results.table", {NullCell, SubTable, Cell}

