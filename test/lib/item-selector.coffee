Backbone = require 'backbone'

class TableCell extends Backbone.Model

class Cells extends Backbone.Collection

  model: TableCell

class Item extends Backbone.View

  tagName: 'tr'

  initialize: ({@selected}) ->
    @setSelected()
    @listenTo @selected, 'add remove', @setSelected
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

  render: -> @$el.html """
    <td>
      <input type="checkbox" #{ if @model.get('selected') then 'checked' else '' }>
    </td>
    <td>
      #{ @model.escape 'value' }
    </td>
    <td>
      #{ @model.escape 'class' }
    </td>
  """

class Items extends Backbone.View

  tagName: 'table'

  className: 'table selectable-items'

  initialize: ({@selected}) ->
    @listenTo @collection, 'add', @addItem

  addItem: (model) -> if @$tbody
    item = new Item {model, @selected}
    item.$el.appendTo @$tbody
    item.render()

  render: ->
    @$el.html """
      <thead>
        <tr>
          <th></th>
          <th>Name</th>
          <th>Type</th>
        </tr>
      </thead>
      <tbody></tbody>
    """
    @$tbody = @$ 'tbody'
    @collection.each (m) => @addItem m

# :: Query -> int -> Collection -> ()
module.exports = (query, column, objects) ->
  items = new Backbone.Collection
  itemsView = new Items collection: items, selected: objects
  itemsView.$el.appendTo 'body'
  itemsView.render()

  query.tableRows().then (rows) -> for row in rows
    items.add row[column]

  return null

