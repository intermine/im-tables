{Promise} = require 'es6-promise'

Options = require '../options'
Page = require '../models/page'

CACHES = {}
ALREADY_DONE = Promise.resolve true

exports.getCache = (query) ->
  xml = query.toXML()
  root = query.service.root
  CACHES[root + ':' + xml] ?= new ResultCache query

# An object that maintains a results cache for a given version of a query. Instances
# of this object should *only* be obtained with the `getCache` method, which
# guarantees that the results will be correct.
#
# note for testing: the required API of the query object is:
#   * has `clone` method that returns an object with a `tableRows(page)` method,
#   which when called returns a `Promise<[[TableCellResult]]>`
#
class ResultCache

  offset: 0 # :: int
  rows: null # []? - single contiguous cache of rows.

  constructor: (query) ->
    @query = query.clone() # freeze this query, so it does not change.

  toString: -> if @rows?.length
    "ResultCache(#{ @offset } .. #{ @offset + @rows.length })"
  else
    "ResultCache(EMPTY)"

  # This is *the* primary external public API method. All others should be
  # considered private.
  #
  # :: start :: int, size :: int?  -> Promise<rows>
  fetchRows: (start = 0, size = null) ->
    page = new Page start, size
    updating = @upateCache page
    updating.then => @getRows page

  updateCache: (page) ->
    return ALREADY_DONE if @contains page

    # Return a promise to update the cache
    p = @getRequestPage page
    console.debug 'requesting', p

    # @overlayTable() # FIXME - move overlay stuff back to table.
    # fetching.then @removeOverlay, @removeOverlay
    return @query.tableRows start: p.start, size: p.size
                 .then @addRowsToCache p

  contains: (page) ->
    cache = @rows
    # We definitely don't have it if we don't have any results cached.
    return false unless cache?.length
    end = @offset + cache.length
 
    # We need new data if the range of this request goes beyond
    # that of the cached values, or if all results are selected.
    return (not page.all()) and (page.start >= @offset) and (page.end() <= end)

  dropRows: ->
    @rows = null
    @offset = 0

  # Transform a table page into a larger request page.
  getRequestPage: (page) ->
    cache = @rows
    factor = Options.get 'TableResults.CacheFactor'
    requestLimit = Options.get 'TableResults.RequestLimit'
    size = if page.all() then null else page.size * factor

    # Can ignore the cache if it hasn't been set, just return the expanded page.
    return new Page(page.start, size) unless cache?

    upperBound = @offset + cache.length

    # When paging backwards - extend page towards 0.
    start = if page.all() or page.start >= offset
      page.start
    else
      Math.max 0, page.start - size

    requestPage = new Page(start, size)

    # Don't permit gaps, so try to keep the cache contiguous.

    # We only care if the requestPage is entirely left or right of the current cache.
    if gap = requestPage.leftGap @offset
      if (gap + requestPage.size) > requestLimit
        @dropRows() # prefer to dump the cache rather than request this much
      else
        requestPage.size += gap
    else if gap = requestPage.rightGap upperBound
      if (gap + requestPage.size) > requestLimit
        @dropRows() # prefer to dump the cache rather than request this much
      else
        page.size += gap
        page.start = upperBound

    return requestPage

  # Update the cache with the retrieved results. If there is an overlap 
  # between the returned results and what is already held in cache, prefer the newer 
  # results.
  #
  # @param page The page these results were requested with.
  # @param rows The rows returned from the server.
  #
  addRowsToCache: (page) -> (rows) =>
    cache = @rows
    offset = @offset
    if cache? # may not exist if this is the first request, or we have dumped the cache.
      upperBound = @offset + cache.length

      # Add rows we don't have to the front - TODO: use splice rather than slice!
      if page.start < offset
        if page.end() < offset
          throw new Error("Cannot add #{ page } to #{ @ } - non contiguous")
        if page.all() or page.end() > upperBound
          cache = rows.slice() # containment, rows replace cache.
        else # concat together
          cache = rows.concat cache.slice page.end() - offset
      else if page.start > upperBound
        throw new Error("Cannot add #{ page } to #{ @ } - non contiguous")
      else if page.all() or upperBound < page.end()
        # Add rows we don't have to the end
        cache = cache.slice(0, (page.start - offset)).concat(rows)
      else
        console.error "Useless cache add - we already had these rows: #{ page }"

      offset = Math.min offset, page.start
    else
      cache = rows.slice()
      offset = page.start

    @offset = offset
    @rows = cache

  # Extract the given rows from the cache. When this method is called the
  # cache must have been populated by `updateCache`, so don't call it
  # directly.
  getRows: ({start, size}) ->
    throw new Error 'Cache has not been updated' unless @rows?
    rows = @rows.slice() # copy the cached rows, so we don't truncate the cache.
    # Splice off the undesired sections.
    rows.splice(0, start - @offset)
    rows.splice(size, rows.length) if (size? and size > 0)
    return rows

exports.ResultCache = ResultCache # exported for testing.
