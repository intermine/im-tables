_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

require '../../messages/summary'

module.exports = class SummaryHeading extends CoreView

  className: 'im-summary-heading'

  modelEvents: -> change: @reRender
  stateEvents: -> change: @reRender

  renderRequires: ['numeric', 'available', 'got', 'uniqueValues']

  template: Templates.template 'summary_heading'

  getData: -> _.extend super, filtered: @model.get('filteredCount')?

