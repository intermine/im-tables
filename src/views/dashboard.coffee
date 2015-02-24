CoreView = require '../core-view'

History         = require '../models/history'
TableModel      = require '../models/table'
SelectedObjects = require '../models/selected-objects'
{Bus}           = require '../utils/events'

Table      = require './table'
QueryTools = require './query-tools'

ERR = 'Bad arguments to Dashboard - {query} is required'

module.exports = class Dashboard extends CoreView

  tagName: 'div'

  className: 'imtables-dashboard container-fluid'

  Model: TableModel

  initialize: ({query}) ->
    throw new Error(ERR) unless query?
    super
    @history = new History
    @bus = new Bus
    @history.setInitialState query
    @selectedObjects = new SelectedObjects query.service

  renderChildren: ->
    @renderQueryTools()
    @renderTable()

  renderTable: ->
    table = new Table {@model, @history, @selectedObjects}
    @renderChild 'table', table

  renderQueryTools: ->
    tools = new QueryTools {tableState: @model, @history, @selectedObjects, @bus}
    @renderChild 'tools', tools

  remove: ->
    @bus.destroy()
    @history.close()
    super
