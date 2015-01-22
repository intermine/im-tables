_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

ClassSet = require '../../utils/css-class-set'

tabClassSet = (tab, state) ->
  defs = active: -> state.get('currentTab') is tab
  defs["im-#{ tab }-tab"] = true
  new ClassSet defs

module.exports = class ColumnManagerTabs extends CoreView

  template: Templates.template 'column-manager-tabs'

  getData: -> _.extend super, classes: @classSets

  initState: ->
    @state.set currentTab: 'view'

  initialize: ->
    super
    @initClassSets()

  stateEvents: -> 'change:currentTab': @reRender

  events: ->
    'click .im-view-tab': 'selectViewTab'
    'click .im-sortorder-tab': 'selectSortOrderTab'

  selectViewTab: -> @state.set currentTab: 'view'

  selectSortOrderTab: -> @state.set currentTab: 'sortorder'

  initClassSets: ->
    @classSets = {}
    for tab in ['view', 'sortorder'] then do (tab) =>
      @classSets[tab] = tabClassSet tab, @state

