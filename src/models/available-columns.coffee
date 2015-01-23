Collection = require '../core/collection'
PathModel = require './path'

cmp = (f, a, b) ->
  [fa, fb] = (f x for x in [a, b])
  if fa < fb
    -1
  else if fa > fb
    1
  else
    0

partsLen = (m) -> m.get('parts').length
displayName = (m) -> m.get 'displayName'

module.exports = class AvailableColumns extends Collection

  model: PathModel

  initialize: ->
    super
    @on 'change:parts change:displayName', => @sort()

  comparator: (a, b) -> # sort by path-length, and then lexically by attribute name.
    (cmp partsLen, a, b) or (cmp displayName, a, b)

