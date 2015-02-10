CoreView = require '../../core-view'
Options = require '../../options'
TypeAssertions = require '../../core/type-assertions'
HeaderModel = require '../../models/header'
NestedTableModel = require '../../models/nested-table'

# A cell containing a subtable of other rows.
# The table itself can be expanded or collapsed. When collapsed it is represented
# by a summary line.
module.exports = class SubTable extends CoreView

    tagName: "td"
    className: "im-result-subtable"

    Model: NestedTableModel

    parameters: [
      'cellify',
      'canUseFormatter',
      'expandedSubtables'
    ]

    parameterTypes:
      column: (new TypeAssertions.InstanceOf HeaderModel, 'HeaderModel')
      cellify: TypeAssertions.Function
      canUseFormatter: TypeAssertions.Function
      expandedSubtables: TypeAssertions.Collection

    initialize: ->
      super
      @listenTo @expandedSubtables, 'add remove reset', @onChangeExpandedSubtables

    # getPath is part of the RowCell API
    getPath: -> @model.get 'column'

    stateEvents: ->
      'change:open': @onChangeOpen

    onChangeOpen: ->
      if @state.get('open')
        @renderTable().slideDown()
      else
        @$('.im-subtable').slideUp()

    onChangeExpandedSubtables: ->
      @state.set open: @expandedSubtables.contains @getPath()

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

      openInitially = Options.get 'Subtables.Initially.expanded'

      if openInitially
        @toggleTable()

      this

