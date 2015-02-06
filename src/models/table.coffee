Options = require '../options'

class TableModel extends CoreModel

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

