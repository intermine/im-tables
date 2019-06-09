CACHE = {}

getKey = (query, path) ->
  "#{ query.service.root }:#{ query.service.token }:#{ query.toXML() }:#{ path }"

# (imjs.Query, String) -> Promise<Summary>
exports.getColumnSummary = (query, path, term, limit) ->
  CACHE[getKey query, path, term, limit] ?= do -> query.filterSummary path, term, limit

