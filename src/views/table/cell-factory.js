// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const NestedTableModel = require('../../models/nested-table');
const SubTable = require('./subtable'); // FIXME!
const Cell = require('./cell');

// TODO: remove the service argument and read it from query.service!
// :: (service, opts) -> (cell) -> CellView
// where
// service = Service
// opts = {
//   query :: Query
//   canUseFormatter :: fn -> bool,
//   expandedSubtables :: Collection,
//   popoverFactory :: PopoverFactory,
//   selectedObjects :: SelectedObjects,
//   tableState :: TableModel
//   getFormatter :: fn (path) -> (obj, service) -> string
// }
// CellView = Cell | SubTable
module.exports = function(service, opts) {
  let cellify;
  const base = service.root.replace(/\/service\/?$/, "");
  const getFormatter = function(cell) {
    const f = opts.getFormatter(cell.get('node'), cell.get('column'));
    if ((f != null) && opts.canUseFormatter(f)) { return f; } else { return null; }
  };

  return cellify = function(cell) {
    if (cell instanceof NestedTableModel) {
      return new SubTable({
        query: opts.query,
        model: cell,
        cellify,
        expandedSubtables: opts.expandedSubtables
      });
    } else {
      return new Cell({
        model: cell,
        service,
        popovers: opts.popoverFactory,
        selectedObjects: opts.selectedObjects,
        tableState: opts.tableState,
        formatter: (getFormatter(cell))
      });
    }
  };
};

