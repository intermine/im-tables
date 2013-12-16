_ = require 'underscore'

# Thorough deep cloner.
# @param obj The object to clone
module.exports = copy = (obj) ->
  return obj unless _.isObject obj
  dup = if _.isArray(obj) then [] else {}
  for own k, v of obj
    if _.isArray v
      duped = []
      duped.push copy x for x in v
      dup[k] = duped
    else if not _.isObject v
      dup[k] = v
    else
      dup[k] = copy v
  dup

