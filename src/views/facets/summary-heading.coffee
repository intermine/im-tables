_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

module.exports = class SummaryHeading extends CoreView

  className: 'im-summary-heading'

  modelEvents: -> change: @reRender
  stateEvents: -> change: @reRender

  renderRequires: ['available', 'got', 'uniqueValues']

  template: Templates.template 'summary_heading'

  getData: -> _.extend super, filtered: @model.get('filteredCount')?

