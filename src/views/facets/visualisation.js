Options = require '../../options'
CoreView = require '../../core-view'

NumericDistribution = require './numeric'
PieChart = require './pie'
Histogram = require './histogram'
SummaryItems = require './summary-items'

# This child view is essentially a big if statement and dispatcher around
# column summary data.
module.exports = class FacetVisualisation extends CoreView

  className: 'im-facet-vis'

  initialize: ({@range}) -> super

  RERENDER_EVENT: 'change:loading change:numeric change:canHaveMultipleValues'

  # Only show data when there is something to show.
  postRender: -> if @model.get('initialized')
    @renderChild 'vis', @getVisualization()

  # Get the correct implementation to delegate to.
  getVisualization: (args) ->
    {uniqueValues, numeric, canHaveMultipleValues, type, got} = @model.toJSON()
    switch
      when numeric then new NumericDistribution {@model, @range}
      when uniqueValues is 1 then null # nothing to show
      when canHaveMultipleValues then new Histogram {@model}
      when 0 < uniqueValues <= (Options.get 'MAX_PIE_SLICES') then new PieChart {@model}
      when got then new Histogram {@model}
      else null # no chart to show.

