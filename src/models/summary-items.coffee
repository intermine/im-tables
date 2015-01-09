CoreModel = require '../core-model'
Options = require '../options'
{Collection} = require 'backbone'

class SummaryItemModel extends CoreModel

  defaults: ->
    symbol: null
    share: null
    visible: true
    selected: false

module.exports = class SummaryItems extends Collection

  model: SummaryItemModel

  # fetch method is injected. it is of the form (limit, term) -> Promise<Summary>
  initialize: ({@fetch}) ->
    @stats = new CoreModel maxCount: null, loading: false, initialized: false
    @stats.set limit: Options.get 'INITIAL_SUMMARY_ROWS'
    @listenTo @stats, 'change:filterTerm', @onFilterChange
    @listenTo @stats, 'change:summaryLimit', @onLimitChange
    @loadData()

  # These models are ordered, the highest count is *always* first.
  getMaxCount: -> @first()?.get 'count'

  hasAll: -> @stats.get('numeric') or (@stats.get('got') is @stats.get('uniqueValues'))

  onFilterChange: ->
    if @hasAll()
      @filterLocally()
    else
      @loadData 'reset'

  filterLocally: ->
    current = @stats.get 'filterTerm'
    if current?
      parts = current.toLowerCase().split /\s+/
      test = (str) -> _.all parts, (part) -> !!(str and ~str.toLowerCase().indexOf(part))
      @each (x) -> x.set visible: test x.get 'item'
    else
      @each (x) -> x.set visible: true

  increaseLimit: (factor = 2) ->
    limit = factor * @stats.get 'limit'
    @stats.set {limit}

  onLimitChange: ->
    current = @stats.get 'limit'
    previous = @stats.previous 'limit'
    meth = if previous > current then 'reset' else 'add'
    @loadData meth

  setFilterTerm: (filterTerm) -> @stats.set {filterTerm}

  fetchAll: -> @stats.set limit: null

  loadData: (meth = 'add') ->
    @stats.set loading: true
    @fetch(@stats.get('limit'), @stats.get('filterTerm'))
      .then @getSummaryHandler meth
      .then null, (error) => @stats.set {error}

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
      if @size() # very strange - this summary has changed from items to numeric.
        @reset [] # numeric, there are no items, just stats.
    else # this is a frequency based summary - 
      @[meth]({item, count, id: item} for {item, count} in summary)
    @stats.set newStats # triggers all change events - but the collection is already consistent.
