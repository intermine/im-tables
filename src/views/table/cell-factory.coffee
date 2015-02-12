NestedTableModel = require '../../models/nested-table'
SubTable = require './subtable' # FIXME!
Cell = require './cell'

# TODO: remove the service argument and read it from query.service!
# :: (service, opts) -> (cell) -> CellView
# where
# service = Service
# opts = {
#   query :: Query
#   canUseFormatter :: fn -> bool,
#   expandedSubtables :: Collection,
#   popoverFactory :: PopoverFactory,
#   selectedObjects :: SelectedObjects,
#   tableState :: TableModel
#   getFormatter :: fn (path) -> (obj, service) -> string
# }
# CellView = Cell | SubTable
module.exports = (service, opts) ->
  base = service.root.replace /\/service\/?$/, ""
  cellify = (cell) ->
    if cell instanceof NestedTableModel
      return new SubTable
        query: opts.query
        model: cell
        cellify: cellify
        canUseFormatter: opts.canUseFormatter
        expandedSubtables: opts.expandedSubtables
    else
      return new Cell
        model: cell
        service: service
        popovers: opts.popoverFactory
        selectedObjects: opts.selectedObjects
        tableState: opts.tableState
        formatter: (opts.getFormatter cell.get('node'))

