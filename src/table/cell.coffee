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
          @cellify = @options.cellify
          @path = @get('column') # Cell Views must have a path :: PathInfo property.
          @model.on 'expand', => @renderTable().slideDown()
          @model.on 'collapse', => @$('.im-subtable').slideUp()

        get: (key) -> @model.get key

        getSummaryText: () ->
          def = jQuery.Deferred()
          column = @get 'column'
          rows = @get 'rows'
          query = @get 'query'

          if column.isCollection()
              def.resolve """#{ rows.length } #{ @get 'columnTypeName' }s"""
          else
              # Single collapsed reference.
              if rows.length is 0
                view_0 = @get('view')[0]
                # find the outer join:
                level = if query.isOuterJoined(view_0)
                    query.getPathInfo query.getOuterJoin view_0
                else
                    column
                typePath = query.model.getPathInfo level.getType()
                typePath.getDisplayName().then (name) -> def.resolve """
                    <span class="im-no-value">No #{ name }</span>
                  """
              else # We hope that this is sensible and has a main object at the head position.
                [first_row] = @get 'rows' # TODO - deal with nested sub tables
                [main, attrs...] = first_row.map (c) -> c.get 'value'
                def.resolve """#{main} (#{attrs.join(', ')})"""
          def.promise()

        getEffectiveView: ->
          # TODO: refactor the common code between this and Table#getEffectiveView
          {getReplacedTest, longestCommonPrefix} = intermine.utils
          {shouldFormat, getFormatter} = intermine.results
          query = @get 'query'
          [row] = @get 'rows' # use first row as pattern for all of them
          replacedBy = {}
          explicitReplacements = {}

          # cell is either CellModel or NestedTableModel
          columns = for cell in row
            [path, replaces] = if cell.has('view') # subtable of this cell
              commonPrefix = longestCommonPrefix cell.get('view')
              path = query.getPathInfo commonPrefix
              [path, (query.getPathInfo sv for sv in cell.view)]
            else
              path = cell.get 'column'
              [path, [path]]
            {path, replaces}

          for c in columns when c.path.isAttribute() and shouldFormat c.path
            parent = c.path.getParent()
            replacedBy[parent] ?= c
            formatter = getFormatter c.path
            if @options.canUseFormatter formatter
              c.isFormatted = true
              c.formatter = formatter
              for fieldExpr in (formatter.replaces ? [])
                subPath = query.getPathInfo "#{ parent }.#{ fieldExpr }"
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
          columnName = @get 'columnName'
          query = @get 'query'
          for c in columns then do (c) ->
            th = $ """<th>
                <i class="#{intermine.css.headerIconRemove}"></i>
                <span></span>
            </th>"""
            th.find('i').click -> query.removeFromSelect c.replaces
            $.when(columnName, c.path.getDisplayName()).then (tableName, colName) ->
              text = if colName.match(tableName)
                  colName.replace(tableName, '').replace(/^\s*>?\s*/, '')
              else
                  colName.replace(/^[^>]*\s*>\s*/, '')
              span = th.find('span').text text

            th.appendTo headers

        appendRow: (columns, row, tbody) ->
          tbody ?= @$ '.im-subtable tbody'
          tr = $ '<tr>'
          w = @$el.width() / @get('view').length
          processed = {}
          replacedBy = {}
          for c in columns
            for r in c.replaces
              replacedBy[r] = c

          # Actual rendering happens here - subsequent code just determines whether to use.
          cellViews = row.map @cellify

          for cell in cellViews then do (tr, cell) ->
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
            cell.render()

          tr.appendTo tbody
          null # Called in void context, no need to collect results.

        renderTable: ($table) ->
          $table ?= @$ '.im-subtable'
          return $table if @tableRendered
          tbody = $table.find 'tbody'
          thead = $table.find 'thead tr'
          rows = @get 'rows'
          if rows.length > 0
            tbodyFrag = document.createDocumentFragment()
            theadFrag = document.createDocumentFragment()
            columns = @getEffectiveView()
            @renderHead theadFrag, columns

            if @column.isCollection()
                @appendRow(columns, row, tbodyFrag) for row in rows
            else
                @appendRow(columns, rows[0], tbodyFrag) # Odd hack to fix multiple repeated rows.

            thead.html theadFrag
            tbody.html tbodyFrag
          @tableRendered = true
          $table

        events:
          'click .im-subtable-summary': 'toggleTable'

        toggleTable: (e) ->
          e?.stopPropagation()
          $table = @$ '.im-subtable'
          evt = if $table.is ':visible'
            'collapsed'
          else
            @renderTable $table
            'expanded'
          $table.slideToggle()
          @model.trigger 'evt'

        render: () ->
          icon = if @get('rows').length > 0
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

    class Cell extends Backbone.View
        tagName: "td"
        className: "im-result-field"

        formatter: (imobject) ->
          field = @model.get('field')
          if imobject.get(field)?
            imobject.escape field
          else
            """<span class="null-value">&nbsp;</span>"""

        initialize: ->
          @model.get('cell').on 'change', @selectingStateChange, @
          @model.get('cell').on 'change', @updateValue, @

          @listenToQuery @model.get 'query'

          @path = @model.get('column') # Cell Views must have a path :: PathInfo property.

        remove: ->
          @model.off()
          @model.get('cell').off 'change', @selectingStateChange
          @model.get('cell').off 'change', @updateValue
          @popover?.remove()
          super

        events: ->
          'shown': => @cellPreview?.reposition()
          'show': (e) =>
            @model.get('query').trigger 'showing:preview', @el
            e?.preventDefault() if @model.get('cell').get 'is:selecting'
          'hide': (e) => @model.get('cell').cachedPopover?.detach()
          'click': 'activateChooser'
          'click a.im-cell-link': (e) =>
            # Prevent bootstrap from closing dropdowns, etc.
            e?.stopPropagation()
            # Allow the table to handle this event, if
            # it chooses to.
            e.object = @model # one arg good, more args bad.
            @options.query.trigger 'object:view', e

        reportClick: -> @model.get('cell').trigger 'click', @model.get('cell')

        listenToQuery: (q) ->
          onListCreation = =>
            @model.get('cell').set 'is:selecting': true
          onStopListCreation = =>
            @model.get('cell').set 'is:selecting': false, 'is:selected': false
          onShowingPreview = (el) => # Close ours if another is being opened.
            @cellPreview?.hide() unless el is @el
          onStartHighlightNode = (node) =>
            if @model.get('node')?.toString() is node.toString()
              @$el.addClass "im-highlight"
          onStopHighlight = => @$el.removeClass "im-highlight"
          listenToReplacement = (replacement) =>
            q.off "start:list-creation", onListCreation
            q.off "stop:list-creation", onStopListCreation
            q.off 'showing:preview', onShowingPreview
            q.off "start:highlight:node", onStartHighlightNode
            q.off "stop:highlight", onStopHighlight
            q.off "replaced:by", listenToReplacement
            @listenToQuery replacement

          q.on "start:list-creation", onListCreation
          q.on "stop:list-creation", onStopListCreation
          q.on 'showing:preview', onShowingPreview
          q.on "start:highlight:node", onStartHighlightNode
          q.on "stop:highlight", onStopHighlight
          q.on "replaced:by", listenToReplacement

        getPopoverContent: =>
          cell = @model.get 'cell'
          return cell.cachedPopover if cell.cachedPopover?

          type = cell.get 'obj:type'
          id = cell.get 'id'

          popover = @popover = new intermine.table.cell.Preview
            service: @model.get('query').service
            schema: @model.get('query').model
            model: {type, id}

          content = popover.$el

          popover.on 'rendered', => @cellPreview.reposition()
          popover.render()

          cell.cachedPopover = content

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
            html: true # well, technically we are using Elements.
            title: => @model.get 'typeName' # function, as not available until render is called
            trigger: intermine.options.CellPreviewTrigger # click or hover
            delay: {show: 250, hide: 250} # Slight delays to prevent jumpiness.
            classes: 'im-cell-preview'
            content: @getPopoverContent
            placement: @getPopoverPlacement

          @cellPreview = new intermine.bootstrap.DynamicPopover @el, options

        updateValue: -> _.defer =>
          @$('.im-displayed-value').html @formatter(@model.get('cell'))

        getInputState: ->
          {selected, selectable, selecting} = @model.get('cell').selectionState()
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
          field = @model.get('field')
          data =
            value: @formatter(@model.get('cell'))
            rawValue: @model.get('value')
            field: field
            url: @model.get('cell').get('service:url')
            host: if IndicateOffHostLinks then window.location.host else /.*/
            icon: null
          _.extend data, @getInputState()

          unless /^http/.test(data.url)
            data.url = @model.get('cell').get('service:base') + data.url

          for domain, url of ExternalLinkIcons when data.url.match domain
            data.icon ?= url
          data

        render: ->
          data = @getData()
          @$el.addClass 'im-type-' + @path.getType().toLowerCase()
          @$el.addClass 'active' if data.checked
          @$el.html CELL_HTML data
          @setupPreviewOverlay() if @model.get('cell').get('id')
          this

        activateChooser: ->
          @reportClick()
          {selected, selectable, selecting} = @model.get('cell').selectionState()
          if selectable and selecting # then toggle state of 'selected'
            @model.set 'is:selected': not selected

    scope "intermine.results.table", {SubTable, Cell}

