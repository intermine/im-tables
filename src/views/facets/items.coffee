_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

# Child views that we delegate to.
SummaryStats = require './summary-stats' # when it is numeric.
SummaryItems = require './summary-items' # when it is a list of items.
OnlyOneItem = require './only-one-item'  # when there is only one.

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

  initialize: ({@range}) -> super

  template: Templates.template 'facet_frequency'

  # model values read by the template or which cause the subviews to need re-creation.
  RERENDER_EVENT: 'change:error change:numeric change:uniqueValues change:initialized'

  # Make model available as state is, as the model has *optional* properties, and so cannot
  # be statically accessed using the standard context lookup mechanism.
  getData: -> _.extend super, model: @model.toJSON()

  # If data has been fetched, then display it.
  postRender: -> if @model.get('initialized')
    @renderChild 'items', @getItems()

  getItems: -> # dispatch to one of the child view implementations.
    if @model.get 'numeric'
      new SummaryStats {@model, @range}
    else if @model.get('uniqueValues') > 1
      new SummaryItems {@model}
    else
      new OnlyOneItem {@model}

