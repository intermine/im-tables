_ = require 'underscore'
CoreView = require '../../core-view'
Templates = require '../../templates'

# This view uses the lists messages bundle.
require '../../messages/lists'

# A component that displays an apology if there are
# no tags to show.
module.exports = class TagsApology extends CoreView

  collectionEvents: ->
    'add remove reset': @reRender

  template: Templates.template 'list-tags-apology'

  getData: -> _.extend super, hasTags: @collection.size()

