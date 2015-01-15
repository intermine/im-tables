PieChart = require './pie'

# The only difference between this class and a regular pie chart is the fact that
# boolean paths do not support multiple selection, which is enforced here.
module.exports = class BooleanChart extends PieChart

  initialize: ->
    super
    @listenTo @model.items 'change:selected', @deselectOthers
    
  # Only one value can be selected at a time (unlike pie charts and histograms,
  # which model multi-selection), so if something gets selected go through all the
  # other items and deselect them.
  deselectOthers: (x, selected) -> if selected
    @model.items.each (m) -> m.deselect() if x isnt m

