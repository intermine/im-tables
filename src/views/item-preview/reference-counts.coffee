_ = require 'underscore'

Templates = require '../../templates'
CoreView = require '../../core-view'

RELATION = Templates.template 'cell-preview-reference-relation'

module.exports = class ReferenceCounts extends CoreView

  className: 'im-related-counts'

  tagName: 'ul'

  collectionEvents: ->
    'add change sort': @reRender

  postRender: ->
    baseData = @getBaseData()
    @collection.each (details) =>
      @$el.append RELATION _.extend details.toJSON(), baseData
    @trigger 'ready'
