define 'table/models/nested-table', ->

  # Forms a pair with table/models/cell
  class NestedTableModel extends Backbone.Model

    initialize: ->
      {query, column} = @toJSON()
      query.on 'expand:subtables', (path) =>
        if path.toString() is column.toString()
          @trigger 'expand'

      query.on 'collapse:subtables', (path) =>
        if path.toString() is column.toString()
          @trigger 'collapse'

      column.getDisplayName().then (name) =>
        @set columnName: name
      query.model.makePath(column.getType()).getDisplayName().then (name) =>
        @set columnTypeName: name

      for evt in ['expanded', 'collapsed'] then do (evt) =>
        @on evt, => @get('query').trigger "subtable:#{ evt }", @get('column')

