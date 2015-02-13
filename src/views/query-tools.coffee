CoreView = require '../core-view'
Templates = require '../templates'

ColumnMangerButton   = require './column-manager/button'
FilterDialogueButton = require './filter-dialogue/button'
JoinManagerButton    = require './join-manager/button'
UndoHistory          = require './undo-history'
ListDialogueButton   = require './list-dialogue/button'
CodeGenButton        = require './code-gen-button'
ExportDialogueButton = require './export-dialogue/button'

SUBSECTIONS = ['im-query-management', 'im-history', 'im-query-consumers']

subsection = (s) -> """<div class="#{ s }"></div>"""

module.exports = class QueryTools extends CoreView

  className: 'im-query-tools'

  parameters: ['tableState', 'history', 'selectedObjects']

  template: ->
    subs = (SUBSECTIONS.map subsection).join ''
    subs + Templates.clear

  initialize: ->
    super
    @listenTo @history, 'changed:current', @renderManagementTools
    @listenTo @history, 'changed:current', @renderQueryConsumers

  renderChildren: ->
    @renderManagementTools()
    @renderUndo()
    @renderQueryConsumers()

  renderManagementTools: ->
    $management = @$ '.im-query-management'
    query = @history.getCurrentQuery()
    @renderChild 'cols', (new ColumnMangerButton {query}), $management
    @renderChild 'cons', (new FilterDialogueButton {query}), $management
    @renderChild 'joins', (new JoinManagerButton {query}), $management

  renderUndo: ->
    $undo = @$ '.im-history'
    @renderChild 'undo', (new UndoHistory {collection: @history}), $undo

  renderQueryConsumers: ->
    $consumers = @$ '.im-query-consumers'
    query = @history.getCurrentQuery()
    selected = @selectedObjects
    $consumers.empty()
    @renderChild 'save', (new ExportDialogueButton {query}), $consumers
    @renderChild 'code', (new CodeGenButton {query}), $consumers
    @renderChild 'lists', (new ListDialogueButton {query, selected}), $consumers
    $consumers.append Templates.clear

