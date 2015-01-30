
module.exports =
  'table.header.FailedToInitSortMenu': 'Could not initialise the sorting menu.'
  'table.header.FailedToInitFilter': 'Could not initialise the filter menu.'
  'table.header.FailedToInitSummary': 'Could not intitialise the column summary.'
  'table.header.ViewSummary': 'View column summary'
  'table.header.ToggleColumn': 'Toggle column visibility'
  'table.header.RemoveColumn': 'Remove this column'
  'table.header.SortColumn': """
    <% if (dir === 'ASC') { %>
      Sorted in ascending order.
    <% } else if (dir === 'DESC') { %>
      Sorted in descending order.
    <% } else { %>
      Sort this column.
    <% } %>
  """
  'table.header.ToggleTables': 'Expand/collapse all sub-tables'
  'table.header.Composed': """
    This column replaces <%= replaces.length %> others. Click here
    to show the individual columns separately.
  """
  'table.header.FilterTitle': """
    <% if (count > 0) { %>
      <%= count %> active filters.
    <% } else { %>
      Filter by values in this column.
    <% } %>
  """
