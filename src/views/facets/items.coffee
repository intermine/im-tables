_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

# Child views that we delegate to.
SummaryStats = require './summary-stats' # when it is numeric.
SummaryItems = require './summary-items' # when it is a list of items.
OnlyOneItem = require './only-one-item'  # when there is only one.
NoResults = require './no-results'       # when there is nothing

# This class presents the items contained in the summary information, either
# as a list for frequencies, or showing statistics for numerical summaries.
# It is also responsible for showing an error message in case one needs to be shown,
# and a throbber while we are loading data.
#
# In this case we cannot just delegate directly to one of SummaryStats or SummaryItems,
# since we cannot predict until we have results whether a path will be summarised as
# a numerical distribution or as a count of items.
module.exports = class FacetItems extends CoreView

  className: 'im-facet-items'

  # This model has a reference to the NumericRange model, so it can
  # be passed on the SummaryStats child if this path turns out to be numeric.
  initialize: ({@range}) -> super

  template: Templates.template 'facet_frequency'

  # model values read by the template or which cause the subviews to need re-creation.
  RERENDER_EVENT: 'change:error change:numeric change:uniqueValues change:initialized'

  # If data has been fetched, then display it.
  postRender: -> if @model.get('initialized')
    @renderChild 'items', @getItems()

  # dispatch to one of the child view implementations.
  getItems: -> switch
    when @model.get 'numeric'            then new SummaryStats {@model, @range}
    when @model.get('uniqueValues') > 1  then new SummaryItems {@model}
    when @model.get('uniqueValues') is 0 then new OnlyOneItem {@model}
    else new NoResults {@state}

