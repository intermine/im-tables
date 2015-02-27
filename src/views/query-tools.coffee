_ = require 'underscore'
$ = require 'jquery'

CoreView = require '../core-view'
Templates = require '../templates'
Options = require '../options'

ColumnMangerButton   = require './column-manager/button'
FilterDialogueButton = require './filter-dialogue/button'
JoinManagerButton    = require './join-manager/button'
UndoHistory          = require './undo-history'
ListDialogueButton   = require './list-dialogue/button'
CodeGenButton        = require './code-gen-button'
ExportDialogueButton = require './export-dialogue/button'
{Bus}                = require '../utils/events'

SUBSECTIONS = ['im-query-management', 'im-history', 'im-query-consumers']

subsection = (s) -> """<div class="#{ s } clearfix"></div>"""

module.exports = class QueryTools extends CoreView

  className: 'im-query-tools'

  parameters: ['tableState', 'history', 'selectedObjects']

  optionalParameters: [
    'bus', # An event bus
    'consumerContainer',
    'consumerBtnClass'
  ]

  bus: (new Bus)

  template: -> (SUBSECTIONS.map subsection).join ''

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

  getConsumerContainer: ->
    if @consumerContainer?
      @consumerContainer.classList.add Options.get('StylePrefix')
      @consumerContainer.classList.add 'im-query-consumers'
      @$('.im-query-management').addClass 'im-has-more-space'
      @$('.im-history').addClass 'im-has-more-space'
      return @consumerContainer
    else
      cons = @$('.im-query-consumers').empty()
      return cons if cons.length

  renderQueryConsumers: ->
    container = @getConsumerContainer()
    return unless container # No point instantiating children that won't appear.
    query = @history.getCurrentQuery()
    selected = @selectedObjects
    listDialogue = new ListDialogueButton {query, @tableState, selected}
    @listenTo listDialogue, 'all', (evt, args...) =>
      @bus.trigger "list-action:#{evt}", args...
      @bus.trigger "list-action", evt, args...

    @renderChild 'save', (new ExportDialogueButton {query, @tableState}), container
    @renderChild 'code', (new CodeGenButton {query, @tableState}), container
    @renderChild 'lists', listDialogue, container

    if @consumerContainer and @consumerBtnClass
      for kid in ['save', 'code', 'lists']
        console.log 'listening to', @children[kid]
        @listenTo @children[kid], 'rendered', @setButtonStyle

    @setButtonStyle()

  setButtonStyle: ->
    if (con = @consumerContainer) and (cls = @consumerBtnClass)
      $('.btn', con).addClass(cls)

