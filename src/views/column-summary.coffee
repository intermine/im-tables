_ = require 'underscore'

{Model: {NUMERIC_TYPES}} = require 'imjs'

NumericFacet = require './facets/numeric'
FrequencyFacet = require './facets/frequency'

# Factory function that returns the appropriate type of summary based on the
# type of the path (numeric or non-numeric).
exports.create = (args) ->
  return new FrequencyFacet args # remove this factory??

  path = args.view
  attrType = path.getType()
  initialLimit = Options.get 'INITIAL_SUMMARY_ROWS'
  Facet = if attrType in NUMERIC_TYPES
    NumericFacet # FIXME FIXME - combine into FrequencyFacet!!
  else
    FrequencyFacet

  new Facet args

