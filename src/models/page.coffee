module.exports = class Page

  # Build a new page
  # @param start [Natural] The start index (start != null && start >= 0)
  # @param size [Natural?] the size of the page (size == null || size >= 0)
  constructor: (@start, @size = null) ->
    throw new Error('Start must be >= 0') unless (@start? and @start >= 0)
    throw new Error('Size must be null or Natural') if @size? and @size < 0

  # Get the end of this page (the index one past the last index)
  # eg. for Page(0, 10) the end is 10
  #     for Page(0) the end is null
  end: -> if @all() then null else @start + @size

  # Is this page unbounded to the right? True if size == null or size === 0
  all: -> !@size

  # Is this page fully to the left of the given zero-based index?
  isBefore: (index) -> @size? and @end() < index

  # Is this page fully to the right of the given zero-based index?
  isAfter: (index) -> index < @start

  # How many spaces are there between the given index and this page, on the left?
  # eg. let this = new Page(10, 10) then leftGap 8 = 2
  #     let this = new Page(10, 10) then leftGap 10 = null
  #     let this = new Page(10, 10) then leftGap 12 = null
  leftGap: (index) -> if @isAfter index then @start - index else null

  # How many spaces are there between the given index and this page, on the right?
  # eg. let this = new Page(10, 10) then leftGap 8 = null
  #     let this = new Page(10, 10) then leftGap 20 = null
  #     let this = new Page(10, 10) then leftGap 22 = 2
  rightGap: (index) -> if @isBefore index then index - @end() else null

  # Get the page after this page.
  next: -> new Page @end(), @size

  # Get the page before this page.
  prev: -> new Page (Math.max 0, @start - @size), @size

  # Get a string representation of this page, eg. "Page(10 .. 20)"
  toString: -> "Page(#{ @start } .. #{ @end() })"
