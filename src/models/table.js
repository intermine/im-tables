Options = require '../options'
CoreModel = require '../core-model'
PathSet = require './path-set'

module.exports = class TableModel extends CoreModel

  defaults: ->
    phase: 'FETCHING' # FETCHING, SUCCESS or ERROR
    start: 0
    size: (Options.get 'DefaultPageSize')
    count: null
    fill: 0 # counter of the number of times we have filled the rows
    error: null
    selecting: false # are we picking objects from the table?
    previewOwner: null # Who owns the currently displayed preview?
    highlitNode: null # Which node should we be highlighting?
    minimisedColumns: (new PathSet)

  initialize: ->
    minimisedColumns = @get 'minimisedColumns'
    @listenTo minimisedColumns, 'add remove reset', -> @trigger 'change:minimisedColumns change'
    @freeze 'minimisedColumns'

  filled: => @swap 'fill', (n) -> n + 1

  toJSON: ->
    data = super
    data.minimisedColumns = @get('minimisedColumns').toJSON().map String
    return data

  destroy: ->
    @get('minimisedColumns').close()
    super

