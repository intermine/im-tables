UniqItems = require './uniq-items'
Backbone = require 'backbone'

# Differs in terms of the definition of containment, which is specialised for paths
module.exports = class PathSet extends UniqItems

  paths: -> @map (model) -> model.get 'item'

  # True for X.y if X.y.z is open
  contains: (path) -> @any (model) -> path.equals model.get 'item'

  toggle: (path) -> if (@contains path) then (@remove path) else (@add path)

  remove: (path) ->
    if path instanceof Backbone.Model
      return super

    delendum = @find (model) -> path.equals model.get 'item'
    if delendum?
      super delendum

