CoreView = require '../../core-view'
SubtableHeader = require './subtable-header'

# This class renders the rows and column headers of
# nested subtables. It is a thin wrapper around the 
# subcomponents that render the column headers and
# cells.
module.exports = class SubtableInner extends CoreView

  tagName: 'table'

  className: 'im-subtable table table-condensed table-striped'

  parameters: [ # things we want from the SubTable
    'query'
    'headers',
    'model',
    'rows',
    'cellify',
  ]

  render: ->
    @removeAllChildren()
    @el.innerHTML = '' if @rendered
    @renderHead() if @headers.length > 1
    tbody = document.createElement('tbody')
    for row, i in @rows
      @appendRow row, i, tbody
    @el.appendChild tbody
    @trigger 'rendered', @rendered = true
    return this

  renderHead: (table) ->
    head = new SubtableHeader
      query: @query
      collection: @headers
      columnModel: @model
    @renderChild 'thead', head, table

  appendRow: (row, i, tbody) ->
    tr = document.createElement 'tr'
    tbody.appendChild tr
    for cell, j in row
      @renderChild "cell-#{ i }-#{ j }", @cellify(cell), tr
    return null

    # FIXME - the code below deals with the consequences of formatting. Do sth about it.

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

