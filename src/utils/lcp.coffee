_ = require 'underscore'

module.exports = longestCommonPrefix = (paths) ->
  parts = paths[0].split /\./
  prefix = parts.shift() # Root, must be common prefix.
  prefixesAll = (pf) -> _.all paths, (path) -> 0 is path.indexOf pf
  for part in parts when prefixesAll nextPrefix = "#{prefix}.#{part}"
    prefix = nextPrefix
  prefix

