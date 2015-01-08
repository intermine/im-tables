Options = require '../../options'
CoreView = require '../../core-view'
Templates = require '../../templates'
FacetView = require './facet-view'

# FIXME - these need fixing
BooleanFacet = require './boolean'
PieFacet = require './pie'
HistoFacet = require './histogram'

{Model: {BOOLEAN_TYPES}} = require 'imjs'

{setColumnSummary} = require '../../services/column-summary'

module.exports = class FrequencyFacet extends FacetView

  RERENDER_EVT: 'change:error change:got'

  template: Templates.template 'facet_frequency'

  getData: -> _.extend super, model: @model.toJSON() # Make model available as state is.

  postRender: ->
    return unless @model.has 'got'
    Vizualization = @getVizualization()
    child = new Vizualization {@model, @query, @view, @collection, @fetchSummary}
    @renderChild 'viz', child

  getVizualization: ->
    return HistoFacet if @query.canHaveMultipleValues @view
    switch
      when @view.getType() in BOOLEAN_TYPES then BooleanFacet
      when @model.get('uniqueValues') <= Options.get('MAX_PIE_SLICES') then PieFacet
      else HistoFacet
