_ = require 'underscore'
Backbone = require 'backbone'

class TableCell extends Backbone.Model

  idAttribute: '_cellId'

class TableCells extends Backbone.Collection

  model: TableCell

allCells = new TableCells

class TableRow extends Backbone.Model

  constructor: (cells, id) ->
    super()
    @set id: id
    @cells = new TableCells
    for cell in cells # one model per cell value.
      c = _.extend {_cellId: (cell.column + ':' + cell.id)}, cell
      allCells.add c
      @cells.add allCells.get c._cellId

  toJSON: -> _.extend super(), cells: @cells.toJSON()

class HeaderModel extends Backbone.Model

  idAttribute: 'path'

class TableRows extends Backbone.Collection

  model: TableRow

class Headers extends Backbone.Collection

  model: HeaderModel

  comparator: 'index'

QUERY_EVTS = 'change:constraints change:views change:sortorder'

th = (m) -> "<th>#{ m.escape 'path' }</th>"

module.exports = class SelectionTable extends Backbone.View

  tagName: 'table'

  className: 'table selectable-items'

  rows: {} # store rows here.

  initialize: ({@selected, query}) ->
    @rows = {} # instance level var.
    @model ?= new Backbone.Model selecting: true
    @collection = new TableRows
    @headers = new Headers
    @listenTo @collection, 'add', @addRow
    @listenTo @collection, 'remove', @removeRow
    @listenTo @headers, 'add remove reset sort', @renderHeaders
    @listenTo @model, 'change:selecting', @render
    @setQuery query if query?

  setQuery: (query) ->
    @stopListening(@query) if @query?
    @query = query
    @listenTo @query, QUERY_EVTS, @populate
    @listenTo @query, 'change:views', @setHeaders
    @setHeaders()
    @populate()

  setHeaders: ->
    @headers.set({path: v, index: i} for v, i in @query.views)
    @headers.sort()

  populate: ->
    xml = @query.toXML() # xml is query key.
    @_pop_called = our_call = _.now()
    @query.tableRows().then (rows) =>
      # Do nothing if another call was made since this one.
      return if @_pop_called isnt our_call
      @collection.set(new TableRow row, "#{ xml }:#{ i }" for row, i in rows)

  addRow: (model) -> if @$tbody
    id = model.get 'id'
    selecting = @model.get 'selecting'
    @rows[id]?.remove() # most likely not necessary, but hey.
    selected = (if selecting then @selected else (new Backbone.Collection))
    row = new Row {model, selected, selecting}
    @rows[id] = row
    row.render().$el.appendTo @$tbody

  removeRow: (model) ->
    @removeRowById model.get 'id'

  removeRowById: (id) ->
    @rows[id]?.remove() # most likely not necessary, but hey.
    delete @rows[id]

  renderHeaders: -> if @$thead
    @$thead.html @headers.map(th).join ''

  render: ->
    @removeAllRows()
    @$el.html """
      <thead><tr></tr></thead>
      <tbody></tbody>
    """
    @$thead = @$ 'thead tr'
    @$tbody = @$ 'tbody'

    @renderHeaders()
    @collection.each (m) => @addRow m
    this

  removeAllRows: ->
    for id of @rows
      @removeRowById id
    @rows = {}

  remove: ->
    @removeAllRows()
    super()

class Row extends Backbone.View

  tagName: 'tr'

  initialize: ({@selected, @selecting}) ->
    @cells = []

  render: ->
    @model.cells.each (model) =>
      cell = new Cell {model, @selected, @selecting}
      cell.render().$el.appendTo @el
      @cells.push cell
    this

  remove: ->
    while c = @cells.pop()
      c.remove()
    super()

NULL = """<code>null</null>"""

class Cell extends Backbone.View

  tagName: 'td'

  initialize: ({@selected, @selecting}) ->
    @setSelected()
    @listenTo @selected, 'add remove reset', @setSelected
    @listenTo @model, 'change:selected', @render

  setSelected: ->
    @model.set selected: @selected.contains @model

  events: ->
    'click': 'toggleSelected'

  toggleSelected: ->
    if @selected.contains @model
      @selected.remove @model
    else
      @selected.add @model

  getChecked: -> if @model.get('selected') then 'checked' else null

  render: ->
    value = if @model.get('value')? then @model.escape('value') else NULL

    if @selecting
      @$el.html """
        <input type="checkbox" #{ @getChecked() } >
        #{ value }
      """
    else
      @$el.html value

    this
