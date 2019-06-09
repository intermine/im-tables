_ = require 'underscore'

CoreModel = require '../core-model'
Collection = require '../core/collection'

# A row in the table, basically just a container for cells.
class RowModel extends CoreModel

  defaults: ->
    index: null
    query: null # string for caching skipsets
    cells: []

  toJSON: -> _.extend super, cells: (c.toJSON() for c in @get 'cells')

# An ordered collection of rows
# It indexes rows by index, so it must be reset if the query changes.
module.exports = class RowsCollection extends Collection

  model: RowModel

  comparator: 'index'

