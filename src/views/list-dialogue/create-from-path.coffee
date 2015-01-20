{Promise} = require 'es6-promise'

# Base class
BaseCreateListDialogue = require './base-dialogue'

module.exports = class CreateFromPath extends BaseCreateListDialogue

  parameters: ['query', 'path']

  className: -> super + ' im-from-path'

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

