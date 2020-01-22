getMissingData = require './fetch-missing-data'
hasData        = require './has-fields'

thenSet = (m, p) -> p.then (data) -> m.set data

# :: (type :: String, fields :: [String]) -> (m :: Model, s :: Service) -> Obj
module.exports = (type, fields) ->
  get = getMissingData type, fields
  complete = hasData fields
  # Setting missing props triggers re-render.
  (m, s) -> (thenSet m, get s, m.get 'id') unless complete m; m.toJSON()
