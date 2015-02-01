_ = require 'underscore'

Collection = require '../core/collection'
PathModel = require './path'

class Join extends PathModel

  defaults: -> _.extend super,
    style: 'INNER'

  constructor: ({path, style}) ->
    super path
    @set {style} if style?

module.exports = class Joins extends Collection

  model: Join

  comparator: 'displayName' # sort lexigraphically.

  initialize: ->
    super
    @listenTo @, 'change:displayName', @sort

# Create an initialized collection from a query, effectively
# snap-shotting the join state.
Joins.fromQuery = (query) ->
  joins = new Joins
  # Add the defined joins.
  for p, style of query.joins
    path = query.makePath p
    joins.add new Join {style, path}
  # Add all the implicit joins.
  for n in query.getQueryNodes()
    while not n.isRoot()
      joins.add new Join path: n # no-op if already in the coll'n
      n = n.getParent()
  return joins

