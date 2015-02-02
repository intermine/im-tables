Options = require '../options'

class TableModel extends CoreModel

  defaults: ->
    selecting: false
    state: 'FETCHING' # FETCHING, SUCCESS or ERROR
    start: 0
    size: (Options.get 'DefaultPageSize')
    count: null,
    lowerBound: null
    upperBound: null
    cache: null
    error: null

