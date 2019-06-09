# ([[name, val]]) -> string
exports.fromPairs = (pairs) ->
  (p.map(encodeURIComponent).join('=') for p in pairs).join('&')

