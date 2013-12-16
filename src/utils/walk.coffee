_ = require 'underscore'

# Simple tree-walker
# @param obj The object to walk.
# @param [(obj, key, value) ->] visit The visitor for each leaf.
module.exports = walk = (obj, visit) ->
  for own k, v of obj
    if _.isObject v
      walk v, visit
    else
      visit obj, k, v
