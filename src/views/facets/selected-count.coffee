_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

require '../../messages/summary'

sum = (lens, xs) ->
  lens ?= _.identity
  _.reduce xs, ((total, x) -> total + lens x), 0

# Sum up the .count properties of the things in an array.
sumCounts = _.partial sum, (x) -> x.count

# Sum up a list of partially overlapping buckets.
sumPartials = (min, max, partials) ->
  sum (_.partial getPartialCount, min, max), partials

# Get the amount of of a given range a particular span overlaps.
# eg: ({min: 0, max: 10}, 0, 10) -> 1
# eg: ({min: 0, max: 10}, 20, 21) -> 0
# eg: ({min: 0, max: 10}, 0, 7) -> 0.7
# eg: ({min: 0, max: 10}, 5, 7) -> 0.2
fracWithinRange = (range, min, max) ->
  return 0 unless range
  rangeSize = range.max - range.min
  overlap = if range.min < min
    Math.min(range.max, max) - min
  else
    max - Math.max(range.min, min)
  overlap / rangeSize

# get a filter to find buckets fully contained in a given range.
fullyContained = (min, max) -> (b) -> b.min >= min and b.max <= max
# get a filter to find buckets partially overlapping a range to its left or right
partiallyOverlapping = (min, max) -> (b) ->
  (b.min < min and b.max > min) or (b.max > max and b.min < max)

# Given a particular span, and a bucket, return an estimate of the number
# of values within the span, assuming that the bucket is evenly populated
# based on the size of the bucket and the amount of overlap.
getPartialCount = (min, max, b) -> b.count * fracWithinRange b, min, max

module.exports = class SelectedCount extends CoreView

  className: 'im-summary-selected-count'

  template: Templates.template 'summary-selected-count'

  stateEvents: ->
    'change:selectedCount change:isApprox': @reRender

  initialize: ({@range}) ->
    super
    @listenTo @model.items, 'change:selected', @estimateSelectionSize
    @listenTo @range, 'change', @estimateSelectionSize

  estimateSelectionSize: ->
    return unless @model.get 'initialized'
    if @model.get 'numeric'
      @estimateSelectedInRange()
    else
      @sumSelectedItems()

  sumSelectedItems: ->
    selected = @model.items.where selected: true
    count = sum ((i) -> i.get 'count'), selected
    @state.set isApprox: false, selectedCount: count

  estimateSelectedInRange: ->
    return @state.unset('selectedCount') if @range.isAll()
    {min, max} = @range.toJSON()
    histogram = @getHistogram()
    fullBuckets = histogram.filter fullyContained min, max
    partials = histogram.filter partiallyOverlapping min, max
    count = Math.round (sumCounts fullBuckets) + (sumPartials min, max, partials)
    @state.set isApprox: true, selectedCount: count

  getHistogram: ->
    buckets = @model.getHistogram()
    maxVal = @model.get 'max'
    minVal = @model.get 'min'
    step = (maxVal - minVal) / buckets.length
    for c, i in buckets
      {count: c, min: (minVal + (i * step)), max: (minVal + step + (i * step))}

