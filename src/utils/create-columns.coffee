longestCommonPrefix = require './longest-common-prefix'

# Create the columns
#
# A column is either a simple column (path is column, empty replaces), or an
# outer-joined collection (where the replaces is the view of the sub-table,
# and the path is the longest common prefix of that view).
#
# :: [RowTemplate] -> Query -> [Column]
# where RowTemplate == {column :: string, view :: [string]?}
#       Column == {path :: PathInfo, replaces :: [PathInfo]}
module.exports = createColumns = (row, query) -> row.map (cell) ->
  if cell.view? # subtable.
    commonPrefix = longestCommonPrefix cell.view
    path = query.makePath commonPrefix
    replaces = (q.getPathInfo(v) for v in cell.view)
  else
    path = query.makePath cell.column
    replaces = []

  {path, replaces}

