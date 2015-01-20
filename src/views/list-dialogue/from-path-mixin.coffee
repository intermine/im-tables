{Promise} = require 'es6-promise'

module.exports = (Base) ->

  parameters: ['query', 'path']

  className: -> Base::className.call(@) + ' im-from-path'

  # :: -> Promise<Query>
  getQuery: -> Promise.resolve @query.selectPreservingImpliedConstraints [@path]

  # :: -> Promise<int>
  fetchCount: ->
    @query.summarise @path
          .then ({stats: {uniqueValues}}) -> uniqueValues

  # :: -> PathInfo?
  getType: -> @query.makePath(@path).getParent().getType()

  # :: -> Service
  getService: -> @query.service


