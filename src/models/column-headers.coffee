Collection = require '../core/collection'
HeaderModel = require './header'

buildHeaders = require '../utils/build-headers'

module.exports = class ColumnHeaders extends Collection

  model: HeaderModel

  comparator: 'index'

  initialize: ->
    super
    @listenTo @, 'change:index', @sort

  # (Query, Collection) -> Promise
  setHeaders: (query, banList) ->
    building = buildHeaders(query, banList)
    building.then (hs) => @set(new HeaderModel h, query for h in hs)

