CACHE = {}

getKey = (query, path) ->
  "#{ query.service.root }:#{ query.service.token }:#{ query.toXML() }:#{ path }"

# (imjs.Query, String) -> Promise<Summary>
exports.getColumnSummary = (query, path, term, limit) ->
  CACHE[getKey query, path, term, limit] ?= do -> query.filterSummary path, term, limit

exports.setColumnSummary = (model, collection, query, path, limit, term) ->
  exports.getColumnSummary(query, path, term, limit)
         .then setSummary(model, collection), setError(model)

setSummary = (model, collection) -> (summary) ->
  # summary has the following properties:
  #  - filteredCount, uniqueValues
  #  if numeric it also has:
  #  - min, max, average, stddev
  # it is also an array, listing the items.
  model.set summary # reads all enumerable properties.
  model.set
    available: Math.max(summary.filteredCount, summary.uniqueValues)
    got: (summary.length)
  if summary.max?
    collection.reset [] # numeric, there are no items.
  else
    # just extract the data we want, and assign ids to so we only add what we
    # don't already have.
    collection.add({item, count, id} for {item, count}, id in items)

setError = (model) -> (error) -> model.set {error}
