_ = require 'underscore'
CoreView = require '../../core-view'
Templates = require '../../templates'
ClassSet = require '../../utils/css-class-set'

module.exports = class QueryProperty extends CoreView

  template: Templates.template 'undo-history-step-section'

  labelContent: -> throw new Error 'NOT IMPLEMENTED'

  summaryLabel: -> thow new Error 'NOT IMPLEMENTED'

  initState: ->
    @state.set open: false

  initialize: ->
    super
    @collectionClasses = new ClassSet
      'well well-sm': true
      'im-hidden': => not @state.get 'open'

  getData: ->
    summaryLabel = _.result @, 'summaryLabel'
    _.extend super, {summaryLabel, @labelContent, @collectionClasses}

  events: ->
    'click .im-section-summary': 'toggleOpen'

  stateEvents: ->
    'change:open': @reRender

  collectionEvents: ->
    'change': @reRender

  toggleOpen: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @state.toggle 'open'


