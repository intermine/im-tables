_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
Formatting = require '../../formatting'
PathSet = require '../../models/path-set'
ColumnHeaders = require '../../models/column-headers'
PopoverFactory = require '../../utils/popover-factory'
History = require '../../models/history'
TableModel = require '../../models/table'
SelectedObjects = require '../../models/selected-objects'
Preview = require '../item-preview'
Types = require '../../core/type-assertions'
CellFactory = require './cell-factory'
TableBody = require './body'
TableHead = require './head'

# Flip the order of arguments.
flip = (f) -> (x, y) -> f y, x

# Inner class that only knows how to render results,
# but not where they come from.
# Also, this is actually a table, with just headers and body.
# Mostly, this class just serves to pass arguments to the children.
module.exports = class ResultsTable extends CoreView

  className: "im-results-table table table-striped table-bordered"

  tagName: 'table'

  throbber: Templates.template 'table-throbber'

  parameters: [
    'history',
    'columnHeaders',
    'rows',
    'tableState',
    'blacklistedFormatters',
    'selectedObjects',
  ]

  parameterTypes:
    history: (Types.InstanceOf History, 'History')
    blacklistedFormatters: Types.Collection
    rows: Types.Collection
    tableState: (Types.InstanceOf TableModel, 'TableModel')
    columnHeaders: (Types.InstanceOf ColumnHeaders, 'ColumnHeaders')
    selectedObjects: (Types.InstanceOf SelectedObjects, 'SelectedObjects')

  initialize: ->
    super
    {service} = @query = @history.getCurrentQuery()
    @expandedSubtables = new PathSet # Owned by the table, used by CellFactory
    @popoverFactory = new PopoverFactory service, Preview
    @cellFactory = CellFactory service, @

    @listenTo @blacklistedFormatters, 'reset add remove', @renderBody
    @listenTo @history, 'changed:current', @setQuery
    
  # We need to maintain the query reference as it is part of the
  # contract of the cell-factory.
  setQuery: -> @query = @history.getCurrentQuery()

  # Retrieve a formatter for a given leaf cell. Used by the cell factory.
  getFormatter: flip Formatting.getFormatter

  # can be used if it exists and hasn't been black-listed.
  # Used by the cell factory (hence bound)
  canUseFormatter: (formatter) =>
    formatter? and (not @blacklistedFormatters.findWhere {formatter})

  renderChildren: ->
    @renderHeaders()
    @renderBody()

  # Add headers to the table
  renderHeaders: ->
    @renderChild 'head', new TableHead (_.pick @, TableHead::parameters)

  renderBody: -> @renderChild 'body', new TableBody
    collection: @rows
    history: @history
    makeCell: @cellFactory

  # Clean up resources we control.
  remove: ->
    @expandedSubtables.close()
    delete @expandedSubtables
    @popoverFactory.destroy()
    delete @popoverFactory
    delete @cellFactory
    super

