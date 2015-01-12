PieChart = require './pie'

module.exports = class BooleanChart extends PieChart

  initialize: ->
    super
    @listenTo @model.items 'change:selected', @deselectOthers
    
  deselectOthers: (x, selected) ->
    @model.items.each (m) -> m.set(selected: false) if (selected and x isnt m)

