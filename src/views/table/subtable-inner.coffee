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

  buildSkipped: (cells) -> @_skipped ?= do =>
    skipped = {}

    # Mark cells we are going to skip, and fix the headers
    # as we go about it.
    for c in cells when c.formatter.replaces?
      n = c.model.get('node').toString()
      col = c.model.get('column')
      p = col.toString()

      if col.isAttribute() and c.formatter.replaces.length > 1
        # Swap out the current header for its parent.
        hi = @headers.indexOf @headers.get p
        @headers.remove p
        @headers.add col.getParent(), at: hi

      for rp in (c.formatter.replaces.map (r) -> n + '.' + r) when rp isnt p
        skipped[rp] = true
        @headers.remove rp # remove the header for the skipped path.
    return skipped

  appendRow: (row, i, tbody) ->
    tr = document.createElement 'tr'
    tbody.appendChild tr
    cells = (@cellify c for c in row)

    skipped = @buildSkipped cells

    for cell, j in cells when not skipped[cell.model.get('column')]
      @renderChild "cell-#{ i }-#{ j }", cell, tr

