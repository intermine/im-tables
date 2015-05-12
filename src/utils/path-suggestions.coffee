_ = require 'underscore'
{Promise} = require 'es6-promise'

# Suggestions can be very large and expensive.
CACHE = {}

matchPathsToNames = (paths) -> (names) ->
  ({path, name} for [path, name] in _.zip paths, names)

module.exports = getPathSuggestions = (query, depth) ->
  key = "#{ query.service.root }:#{ query.root }:#{ depth }"
  return CACHE[key] if key of CACHE
  paths = (query.makePath p for p in query.getPossiblePaths depth)
  paths = paths.filter (p) -> not (p.end?.name is 'id')
  namings = (p.getDisplayName() for p in paths)
  CACHE[key] ?= Promise.all(namings).then matchPathsToNames(paths)
