CoreView = require '../../core-view'
Options = require '../../options'
Collection = require '../../core/collection'
Templates = require '../../templates'
TypeAssertions = require '../../core/type-assertions'
NestedTableModel = require '../../models/nested-table'
PathModel = require '../../models/path'
SubtableHeader = require './subtable-header'

{ignore} = require '../../utils/events'

# A cell containing a subtable of other rows.
# The table itself can be expanded or collapsed.
# When collapsed it is represented
# by a summary line.
module.exports = class SubTable extends CoreView

  tagName: 'td'

  className: 'im-result-subtable'

  Model: NestedTableModel

  parameters: [
    'query',
    'cellify',
    'canUseFormatter',
    'expandedSubtables'
  ]

  parameterTypes:
    query: TypeAssertions.Query
    cellify: TypeAssertions.Function
    canUseFormatter: TypeAssertions.Function
    expandedSubtables: TypeAssertions.Collection

  initialize: ->
    super
    console.log 'SUBTABLE MODEL', @model
    @headers = new Collection
    @listenTo @expandedSubtables, 'add remove reset', @onChangeExpandedSubtables
    @buildHeaders()

  # getPath is part of the RowCell API
  getPath: -> @model.get 'column'

  initState: ->
    @state.set open: Options.get('Subtables.Initially.expanded')

  stateEvents: ->
    'change:open': @onChangeOpen

  modelEvents: ->
    'change:contentName': @reRender

  onChangeOpen: ->
    $wrapper = @$('.im-table-wrapper')
    if @state.get('open')
      @renderTable()
      $wrapper.slideDown()
    else
      $wrapper.slideUp()

  onChangeExpandedSubtables: ->
    @state.set open: @expandedSubtables.contains @getPath()

  events: ->
    'click .im-subtable-summary': @toggleTable

  toggleTable: (e) ->
    ignore e
    @state.toggle 'open'

  template: Templates.template 'table-subtable'

  postRender: ->
    @onChangeOpen()

  renderTable: ->
    $table = @$ '.im-subtable'
    rows = @model.get 'rows'

    return $table if @tableRendered or (rows.length is 0)

    tbody = document.createElement('tbody')

    @renderHead() if @model.get('view').length > 1
    for row, i in rows
      @appendRow row, i, tbody

    # Surely the following is not needed??
    # if not @column.isCollection()
    # @appendRow(columns, rows[0], tbodyFrag) # Odd hack to fix multiple repeated rows.

    $table.append tbody

    @tableRendered = true
    return $table

  ###
  # I don't think this is needed - there should never be single
  # collapsed references. It just shouldn't happen.
  getSummaryText: () ->
    column = @model.get 'column'
    rows = @model.get 'rows'
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
  ###

  buildHeaders: ->
    rows = @model.get('rows')
    return if rows.length is 0
    [row] = rows

    # Use the first row as a pattern.
    @headers.set(new PathModel c.get('column') for c in row)
    console.log @headers

  ###
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
  ###

  renderHead: ->
    $table = @$ '.im-subtable'
    head = new SubtableHeader
      query: @query
      collection: @headers
      columnModel: @model
    @renderChild 'thead', head, $table

  appendRow: (row, i, tbody) ->
    tr = document.createElement 'tr'
    tbody.appendChild tr
    for cell, j in row
      @renderChild "cell-#{ i }-#{ j }", @cellify(cell), tr
    return null

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
