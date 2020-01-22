_ = require 'underscore'
CoreView = require '../core-view'

History         = require '../models/history'
TableModel      = require '../models/table'
SelectedObjects = require '../models/selected-objects'
{Bus}           = require '../utils/events'
Children        = require '../utils/children'
Types           = require '../core/type-assertions'

Table      = require './table'
QueryTools = require './query-tools'

ERR = 'Bad arguments to Dashboard - {query :: imjs.Query} is required'
CC_NOT_FOUND = 'consumerContainer provided as selector - but no matching element was found'

module.exports = class Dashboard extends CoreView

  tagName: 'div'

  className: 'imtables-dashboard container-fluid'

  Model: TableModel

  # :: Element or jQuery-ish or String
  optionalParameters: ['consumerContainer', 'consumerBtnClass']

  initialize: ({query}) ->
    unless Types.Query.test query
      throw new Error(ERR) unless query?
    super
    @history = new History
    @bus = new Bus
    @history.setInitialState query
    @selectedObjects = new SelectedObjects query.service
    # Lift selector to element if provided as such.
    if @consumerContainer? and _.isString @consumerContainer
      @consumerContainer = document.querySelector @consumerContainer
      # If not found then log a message, but do not fail.
      console.log CC_NOT_FOUND unless @consumerContainer

  renderChildren: ->
    @renderQueryTools()
    @renderTable()

  renderTable: ->
    table = Children.createChild @, Table
    @renderChild 'table', table

  renderQueryTools: ->
    tools = Children.createChild @, QueryTools, tableState: @model
    @renderChild 'tools', tools

  remove: ->
    @bus.destroy()
    @history.close()
    super
