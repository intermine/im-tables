_ = require 'underscore'

CoreModel = require '../core-model'
Options = require '../options'
{Collection} = require 'backbone'

{getColumnSummary} = require '../services/column-summary'

inty = (type) -> type in ['int', 'Integer', 'long', 'Long', 'short', 'Short']

# Represents the result of a column summary, and the options that affect it.
# Properties:
#  - filterTerm :: string
#  - maxCount :: int
#  - loading :: bool
#  - initialized :: bool
#  - got :: int
#  - available :: int
#  - filteredCount :: int
#  - uniqueValues :: int
#  - max, min, average, stdev (if numeric) :: floats
#  - numeric :: bool
#  - canHaveMultipleValues :: bool
#  - type :: string (as per PathInfo::getType)
#  - buckets :: int (The number of buckets in the histogram)
module.exports = class SummaryModel extends CoreModel

  defaults: ->
    maxCount: null
    loading: false
    initialized: false
    canHaveMultipleValues: false
    numeric: false
    filterTerm: null

  constructor: ({@query, @view}) ->
    super()
    @fetch = _.partial getColumnSummary, @query, @view
    type = @view.getType()
    integral = inty type
    @set # Initial state - canHaveMultipleValues and type are not expected to change.
      limit: Options.get 'INITIAL_SUMMARY_ROWS'
      canHaveMultipleValues: @query.canHaveMultipleValues(@view)
      type: type
      integral: integral
    @histogram = new SummaryHistogram() # numeric distribution by buckets.
    @items = new SummaryItems()         # Most common items, most frequent first.
    @listenTo @, 'change:filterTerm', @onFilterChange
    @listenTo @, 'change:summaryLimit', @onLimitChange
    @load()

  # The max count is set if the data is initialized.
  getMaxCount: -> @get 'maxCount'

  hasMore: -> (not @get 'numeric') and (@get('got') < @get('uniqueValues'))

  hasAll: -> not @hasMore()

  # Include the items in the JSON output.
  toJSON: -> _.extend super, items: @items.toJSON(), histogram: @getHistogram()

  onFilterChange: ->
    if @hasAll()
      @filterLocally()
    else
      @load()

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

  onLimitChange: -> @load()

  setFilterTerm: (filterTerm) -> @set {filterTerm}

  fetchAll: -> @set limit: null

  load: ->
    @set loading: true
    @fetch((@get 'filterTerm'), (@get 'limit'))
      .then @getSummaryHandler()
      .then null, (error) => @set {error}

  getSummaryHandler: ->
    @lastSummaryHandlerCreatedAt = created = _.now()
    (summary) => @handleSummary created, summary

  getHistogram: -> # histogram can be sparse, hence this method.
    n = @get 'buckets'
    return [] unless n
    for i in [1 .. n] # fill in empty buckets.
      @histogram.get(i)?.get('count') ? 0

  handleSummary: (time, {stats, results}) ->
    # abort if results returned out-of-order, and we are not the most recent.
    return if time isnt @lastSummaryHandlerCreatedAt
    # stats has the following properties:
    #  - filteredCount, uniqueValues
    #  if numeric it also has:
    #  - min, max, average, stdev
    # results is an array, listing the items.
    numeric = stats.max?
    newStats =
      filteredCount: stats.filteredCount
      uniqueValues: stats.uniqueValues
      available: (stats.filteredCount ? stats.uniqueValues) # the most specific of these two
      got: results.length
      numeric: numeric
      initialized: true
      loading: false
    if numeric # - extract the numeric summary values.
      {buckets, max, min, stdev, average} = stats
      _.extend newStats, {buckets, max, min, stdev: parseFloat(stdev), average: parseFloat(average)}
      if @items.size() # very strange - this summary has changed from items to numeric.
        @items.reset() # so there are no items, just stats and buckets
      # Set performs a smart update, with the correct add, remove and change events.
      @histogram.set({item: bucket, count, id: bucket} for {bucket, count} in results)
      newStats.maxCount = @histogram.getMaxCount() # not more than 20, ok to iterate.
    else # this is a frequency based summary
      if @histogram.size() # very strange - this summary has changed from numeric to items
        @histogram.reset() # so there is no histogram.
      # Set performs a smart update, with the correct add, remove and change events.
      @items.set({item, count, id} for {item, count}, id in results)
      newStats.maxCount = @items.getMaxCount()
    @set newStats # triggers all change events - but the collection is already consistent.

class SummaryItemModel extends CoreModel

  # This just lays out the expected properties for this model.
  defaults: ->
    symbol: null
    share: null
    visible: true
    selected: false
    hover: false
    count: 0
    item: null

# This is a collection of SummaryItemModels
class SummaryItems extends Collection

  model: SummaryItemModel

  getMaxCount: -> @first()?.get('count')

# This is a collection of SummaryItemModels
class SummaryHistogram extends Collection

  model: SummaryItemModel

  getMaxCount: -> _.max(b.get('count') for b in @models)
