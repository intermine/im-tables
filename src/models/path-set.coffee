UniqItems = require './uniq-items'

# Differs in terms of the definition of containment, which is specialised for paths
module.exports = class PathSet extends UniqItems

  # True for X.y if X.y.z is open
  contains: (path) -> @any (model) -> path.equals model.get 'item'

  remove: (path) ->
    delendum = @find (model) -> path.equals model.get 'item'
    if delendum?
      super delendum

