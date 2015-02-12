CoreView = require '../../core-view'
SubtableHeader = require './subtable-header'
buildSkipped = require '../../utils/build-skipset'

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

  buildSkipped: (cells) -> @_skipped ?= buildSkipped cells, @headers

  appendRow: (row, i, tbody) ->
    tr = document.createElement 'tr'
    tbody.appendChild tr
    cells = (@cellify c for c in row)

    skipped = @buildSkipped cells

    for cell, j in cells when not skipped[cell.model.get('column')]
      @renderChild "cell-#{ i }-#{ j }", cell, tr

