# PathInfo -> Promise<{path :: String, name :: String}>
module.exports = toNamedPath = (p) -> p.getDisplayName().then (name) ->
  {path: p.toString(), name}
