Options = require '../../options'
CoreView = require '../../core-view'
Templates = require '../../templates'
FacetView = require './facet-view'

# FIXME - these need fixing
BooleanFacet = require './boolean'
PieFacet = require './pie'
HistoFacet = require './histogram'
SummaryItems = require './summary-items'
UniqueValue = require './unique-value'
NoResults = require './no-results'

{Model: {BOOLEAN_TYPES}} = require 'imjs'

{setColumnSummary} = require '../../services/column-summary'

# This class is a wrapper around the different visualisations.
module.exports = class FrequencyFacet extends FacetView

  template: Templates.template 'facet_frequency'

  RERENDER_EVT: 'change:error change:initialized' # model values read by the template.

  getData: -> _.extend super, model: @model.toJSON() # Make model available as state is.

  postRender: ->
    @renderChild 'vis', @getVisualization(), @$ '.im-summary-vis'
    @renderChild 'items', @getItems(), @$ '.im-summary-items'

  getVisualization: (args) ->
    Class = switch
      when @model.get('uniqueValues') is 1 then UniqueValue
      when @model.get('got') is 0 then NoResults
      when @query.canHaveMultipleValues @view then HistoFacet
      when @view.getType() in BOOLEAN_TYPES then BooleanFacet
      when 0 < @model.get('uniqueValues') <= Options.get('MAX_PIE_SLICES') then PieFacet
      when @model.get('got') then HistoFacet
      else null
    new Class {@model, @query, @view, @collection} if Class?

  getItems: ->
    new SummaryItems {@model, @collection, @query, @view} if @model.get('initialized')
