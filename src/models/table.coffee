Options = require '../options'
CoreModel = require '../core-model'
PathSet = require './path-set'

module.exports = class TableModel extends CoreModel

  defaults: ->
    phase: 'FETCHING' # FETCHING, SUCCESS or ERROR
    start: 0
    size: (Options.get 'DefaultPageSize')
    count: null,
    lowerBound: null
    upperBound: null
    cache: null
    error: null
    selecting: false # are we picking objects from the table?
    previewOwner: null # Who owns the currently displayed preview?
    highlitNode: null # Which node should we be highlighting?

  initialize: ->
    @minimisedColumns = new PathSet

  toJSON: ->
    data = super
    data.minimisedColumns = @minimisedColumns.toJSON()
    return data

