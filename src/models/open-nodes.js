Backbone = require 'backbone'
UniqItems = require './uniq-items'

# True if a is b, or b is child of a
descendsFrom = (a, b) ->
  return false if (not a?.equals) or (not b?.isRoot)
  while (not a.equals b)
    # Now either keep going, or give up.
    return false if b.isRoot() # nowhere to go
    b = b.getParent()
  return true

# Differs in terms of the definition of containment. If the node X.y.z is open, then
# X.y will return true for contains.
module.exports = class OpenNodes extends UniqItems

  # True for X.y if X.y.z is open
  contains: (path) ->
    if path instanceof Backbone.Model
      super path
    else
      @any (node) -> descendsFrom path, node.get('item')

  # Also removes sub-nodes.
  remove: (path) ->
    if !path? then return false
    if path instanceof Backbone.Model
      super path

    delenda = @filter (node) -> descendsFrom path, node.get('item')
    for delendum in delenda
      super delendum
