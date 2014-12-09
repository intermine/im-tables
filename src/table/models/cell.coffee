define 'table/models/cell', ->

  # Forms a pair with tables/models/nested-table
  class CellModel extends Backbone.Model

    initialize: ->
      @get('column').getDisplayName().then (name) => @set columnName: name
      type = @get('cell').get('obj:type')
      @get('query').model.makePath(type).getDisplayName().then (name) ->
        @set typeName: name
