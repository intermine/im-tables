// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
const Messages = require('../messages');

Messages.setWithPrefix('table', {
  Building: 'Loading Table ...',
  OverlayText: 'Requesting data...',
  Empty: 'No Results',
  EmptyWhy: 'This query returns no results. You may wish to change its filters'
}
);

Messages.setWithPrefix('table.lg', {
  ShowingAll: 'Showing all <%= formatNumber(count) %> rows',
  ShowingRange: `\
Showing <%= formatNumber(first) %> to <%= formatNumber(last) %>
of <%= formatNumber(count) %> <%= pluralise("row", count) %>\
`
}
);

Messages.setWithPrefix('table.md', {
  ShowingAll: 'All <%= formatNumber(count) %> rows',
  ShowingRange: `\
Showing rows <%= formatNumber(first) %> to <%= formatNumber(last) %>
of <%= formatNumber(count) %>\
`
}
);

Messages.setWithPrefix('table.sm', {
  ShowingAll: 'All rows',
  ShowingRange: `\
Rows <%= formatNumber(first) %> to <%= formatNumber(last) %>
of <%= formatNumber(count) %>\
`
}
);

Messages.setWithPrefix('table.xs', {
  ShowingAll: 'All rows',
  ShowingRange: `\
<%= formatNumber(first) %> to <%= formatNumber(last) %>
of <%= formatNumber(count) %>\
`
}
);

Messages.setWithPrefix('table.header', {
  FailedToInitSortMenu: 'Could not initialise the sorting menu.',
  FailedToInitFilter: 'Could not initialise the filter menu.',
  FailedToInitSummary: 'Could not intitialise the column summary.',
  ViewSummary: 'View column summary',
  ToggleColumn: 'Toggle column visibility',
  RemoveColumn: 'Remove this column',
  SortColumn: `\
<% if (dir === 'ASC') { %>
  Sorted in ascending order.
<% } else if (dir === 'DESC') { %>
  Sorted in descending order.
<% } else { %>
  Sort this column.
<% } %>\
`,
  ToggleTables: 'Expand/collapse all sub-tables',
  Composed: `\
This column replaces <%= replaces.length %> others. Click here
to show the individual columns separately.\
`,
  FilterTitle: `\
<% if (count > 0) { %>
  <%= count %> active filters.
<% } else { %>
  Filter by values in this column.
<% } %>\
`
}
);
