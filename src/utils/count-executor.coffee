# Caching query executor.

CACHE = {}

# A unique key composed of the service we are connected to and the
# canonical representation of the query.
key = (q) -> "#{ q.service.root }:#{ q.service.token }:#{ q.toXML() }"

# Simple caching layer that caches counts.
exports.count = (q) -> CACHE[key q] ?= q.count()

exports.clearCache = -> CACHE = {}

