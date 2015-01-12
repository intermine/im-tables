Options = require '../../options'
CoreView = require '../../core-view'

# FIXME - these need fixing/writing
NumericDistribution = require './numeric'
BooleanPie = require './boolean'
PieChart = require './pie'
Histogram = require './histogram' # TODO fix
SummaryItems = require './summary-items'
UniqueValue = require './unique-value' # TODO write
NoResults = require './no-results' # TODO write

{Model: {BOOLEAN_TYPES}} = require 'imjs'

# This child view is essentially a big if statement and dispatcher around
# column summary data.
module.exports = class FacetVisualisation extends CoreView

  initialize: ({@range}) -> super

  # Only show data when there is something to show.
  postRender: -> if @model.get('initialized')
    @renderChild 'vis', @getVisualization()

  # Get the correct implementation to delegate to.
  getVisualization: (args) ->
    {uniqueValues, numeric, canHaveMultipleValues, type, got} = @model.toJSON()
    switch
      when numeric then new NumericDistribution {@model, @range}
      when uniqueValues is 1 then new UniqueValue {@model}
      when canHaveMultipleValues then new Histogram {@model}
      when type in BOOLEAN_TYPES then new BooleanPie {@model}
      when 0 < uniqueValues <= (Options.get 'MAX_PIE_SLICES') then new PieChart {@model}
      when got then new Histogram {@model}
      else new NoResults

