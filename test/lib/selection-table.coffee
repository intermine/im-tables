_ = require 'underscore'
Backbone = require 'backbone'

class TableCell extends Backbone.Model

class TableCells extends Backbone.Collection

  model: TableCell

allCells = new TableCells

class TableRow extends Backbone.Model

  constructor: (cells, index) ->
    super
    @set id: index
    @cells = new TableCells
    for cell in cells # one cell per object.
      allCells.add cell
      @cells.add allCells.get cell.id

  toJSON: -> _.extend super, cells: @cells.toJSON()

class TableRows extends Backbone.Collection

  model: TableRow

module.exports = class SelectionTable extends Backbone.View

  tagName: 'table'

  className: 'table selectable-items'

  initialize: ({@selected, @query}) ->
    @collection = new TableRows
    @listenTo @collection, 'add', @addRow
    @query.tableRows().then (rows) => for row, i in rows
      @collection.add new TableRow row, i

  addRow: (model) -> if @$tbody
    row = new Row {model, @selected}
    row.render().$el.appendTo @$tbody

  render: ->
    @$el.html """
      <thead><tr></tr></thead>
      <tbody></tbody>
    """
    @$thead = @$ 'thead tr'
    @$tbody = @$ 'tbody'

    @query.views.forEach (view) => @$thead.append """<th>#{ view }</th>"""
    @collection.each (m) => @addRow m
    this

class Row extends Backbone.View

  tagName: 'tr'

  initialize: ({@selected}) ->

  render: ->
    @model.cells.each (model) =>
      cell = new Cell {model, @selected}
      cell.render().$el.appendTo @el
    this

class Cell extends Backbone.View

  tagName: 'td'

  initialize: ({@selected}) ->
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

  render: ->
    @$el.html """
      <input type="checkbox" #{ if @model.get('selected') then 'checked' else null } >
      #{ @model.escape 'value' }
    """
    this

