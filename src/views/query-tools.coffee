CoreView = require '../core-view'
Templates = require '../templates'

ColumnMangerButton   = require './column-manager/button'
FilterDialogueButton = require './filter-dialogue/button'
JoinManagerButton    = require './join-manager/button'

SUBSECTIONS = ['im-query-management', 'im-query-consumers']

module.exports = class QueryTools extends CoreView

  className: 'im-query-tools'

  parameters: ['tableState', 'history', 'selectedObjects']

  template: ->
    sections = ("""<div class="#{ s }"></div>""" for s in SUBSECTIONS).join ''
    sections + Templates.clear

  initialize: ->
    super
    @listenTo @history, 'changed:current', @reRender

  renderChildren: ->
    @renderManagementTools()
    @renderQueryConsumers()

  renderManagementTools: ->
    $management = @$ '.im-query-management'
    query = @history.getCurrentQuery()
    @renderChild 'cols', (new ColumnMangerButton {query}), $management
    @renderChild 'cons', (new FilterDialogueButton {query}), $management
    @renderChild 'joins', (new JoinManagerButton {query}), $management

  renderQueryConsumers: ->


