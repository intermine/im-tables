CoreView = require '../../core-view'
Templates = require '../../templates'

require '../../messages/summary'

# What we display when we display only one thing.
module.exports = class NoResults extends CoreView

  className: 'im-no-results'

  stateEvents: ->
    'change:pathName': @reRender

  template: Templates.template 'summary_no_results'
