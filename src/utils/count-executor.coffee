# Caching query executor.

CACHE = {}

key = (q) -> "#{ q.root }:#{ q.token }:#{ q.toXML() }"

# Simple caching layer that caches counts.
exports.count = (q) -> CACHE[key q] ?= q.count()

exports.clearCache = -> CACHE = {}

