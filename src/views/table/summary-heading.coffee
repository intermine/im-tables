_ = require 'underscore'
pluralise = require 'pluralize'

CoreView = require '../../core-view'
Templates = require '../../templates'

{numToString} = require '../../templates/helpers'

module.exports = class SummaryHeading extends CoreView

  RERENDER_EVT: 'change'

  initialize: ({@query, @view}) ->
    super

  template: Templates.template 'summary_heading'

  getData: -> _.extend {pluralise, filtered: @model.get('filteredCount')?}, super

