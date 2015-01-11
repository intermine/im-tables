_ = require 'underscore'

CoreModel = require '../core-model'
Options = require '../options'
{Collection} = require 'backbone'

# Represents the result of a column summary, and the options that affect it.
# Properties:
#  - maxCount :: int
#  - loading :: bool
#  - initialized :: bool
#  - got :: int
#  - available :: int
#  - filteredCount :: int
#  - uniqueValues :: int
#  - max, min, average, stddev (if numeric) :: floats
#  - numeric :: bool
module.exports = class SummaryModel extends CoreModel

  defaults: ->
    maxCount: null
    loading: false
    initialized: false

  # one parameter - the fetch fn, which closes over query and path.
  constructor: ({@fetch}) ->
    super()
    @set limit: Options.get 'INITIAL_SUMMARY_ROWS'
    @items = new SummaryItems()
    @listenTo @, 'change:filterTerm', @onFilterChange
    @listenTo @, 'change:summaryLimit', @onLimitChange
    @load()

  # These models are ordered, the highest count is *always* first.
  getMaxCount: -> @get 'maxCount' # @items.first()?.get('count')

  hasAll: -> @get('numeric') or (@get('got') is @get('uniqueValues'))

  # Include the items in the JSON output.
  toJSON: -> _.extend super, items: @items.toJSON()

  onFilterChange: ->
    if @hasAll()
      @filterLocally()
    else
      @loadData 'reset'

  # Applies the filter to the current set of items, setting 'visible' accordingly
  filterLocally: ->
    current = @get 'filterTerm'
    if current?
      parts = current.toLowerCase().split /\s+/
      test = (str) -> _.all parts, (part) -> !!(str and ~str.toLowerCase().indexOf(part))
      @items.each (x) -> x.set visible: test x.get 'item'
    else
      @items.each (x) -> x.set visible: true

  increaseLimit: (factor = 2) ->
    limit = factor * @get 'limit'
    @set {limit}

  onLimitChange: ->
    current = @get 'limit'
    previous = @previous 'limit'
    # We can add if we are increasing the limit, otherwise we have to reset, to
    # remove the unwanted items.
    meth = if previous > current then 'reset' else 'add'
    @loadData meth

  setFilterTerm: (filterTerm) -> @set {filterTerm}

  fetchAll: -> @set limit: null

  loadData: (meth = 'add') ->
    @set loading: true
    @fetch((@get 'limit'), (@get 'filterTerm'))
      .then @getSummaryHandler meth
      .then null, (error) => @set {error}

  getSummaryHandler: (meth) ->
    @lastSummaryHandlerCreatedAt = created = _.now()
    (summary) => @handleSummary created, meth, summary

  handleSummary: (time, meth, summary) ->
    # abort if results returned out-of-order, and we are not the most recent.
    return if time isnt @lastSummaryHandlerCreatedAt
    throw new Error("Bad method: #{ meth }") unless meth in ['add', 'reset']
    # summary has the following properties:
    #  - filteredCount, uniqueValues
    #  if numeric it also has:
    #  - min, max, average, stddev
    # it is also an array, listing the items.
    numeric = summary.max?
    newStats =
      filteredCount: summary.filteredCount
      uniqueValues: summary.uniqueValues
      available: (summary.filteredCount ? summary.uniqueValues) # the most specific of these two
      got: summary.length
      numeric: numeric
      initialized: true
      loading: false
    if numeric # - extract the numeric summary values.
      {max, min, stddev, average} = summary
      _.extend newStats {max, min, stddev, average}
      if @items.size() # very strange - this summary has changed from items to numeric.
        @reset [] # numeric, there are no items, just stats.
    else # this is a frequency based summary - 
      @items[meth]({item, count, id} for {item, count}, id in summary)
    @set newStats # triggers all change events - but the collection is already consistent.

class SummaryItemModel extends CoreModel

  # This just lays out the expected properties for this model.
  defaults: ->
    symbol: null
    share: null
    visible: true
    selected: false
    count: 0
    item: null

# This is a collection of SummaryItemModels
class SummaryItems extends Collection

  model: SummaryItemModel

