Templates = require '../../templates'
CoreView = require '../../core-view'

module.exports = class ReferenceCounts extends CoreView

  className: 'im-related-counts'

  tagName: 'ul'

  collectionEvents: -> 'add change sort': @reRender

  template: Templates.template 'cell-preview-reference-relation'
