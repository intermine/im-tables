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
  getFormatter = (cell) ->
    f = opts.getFormatter cell.get('node'), cell.get('column')
    if (f? and opts.canUseFormatter(f)) then f else null

  cellify = (cell) ->
    if cell instanceof NestedTableModel
      return new SubTable
        query: opts.query
        model: cell
        cellify: cellify
        expandedSubtables: opts.expandedSubtables
    else
      return new Cell
        model: cell
        service: service
        popovers: opts.popoverFactory
        selectedObjects: opts.selectedObjects
        tableState: opts.tableState
        formatter: (getFormatter cell)

