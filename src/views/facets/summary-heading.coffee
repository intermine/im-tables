_ = require 'underscore'
pluralise = require 'pluralize'

CoreView = require '../../core-view'
Templates = require '../../templates'

{numToString} = require '../../templates/helpers'

module.exports = class SummaryHeading extends CoreView

  className: 'im-summary-heading'

  initialize: ->
    super
    @listenTo @model, 'change', @reRender
    @listenTo @state, 'change', @reRender

  template: Templates.template 'summary_heading'

  helpers: -> {pluralise}

  getData: -> _.extend super, filtered: @model.get('filteredCount')?

