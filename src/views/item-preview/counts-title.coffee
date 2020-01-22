_ = require 'underscore'

CoreView = require '../../core-view'
Messages = require '../../messages'

Messages.setWithPrefix 'preview',
  RelatedItemsHeading: 'Related Items'

module.exports = class CountsTitle extends CoreView

  tagName: 'h4'

  collectionEvents: -> 'add remove reset': @setVisibility

  setVisibility: -> @$el.toggleClass 'im-hidden', @collection.isEmpty()

  template: -> _.escape Messages.getText 'preview.RelatedItemsHeading'

  postRender: -> @setVisibility()

