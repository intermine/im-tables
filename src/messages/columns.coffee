Messages = require '../messages'

Messages.setWithPrefix 'columns',
  DialogueTitle: 'Manage Columns'
  ApplyChanges: 'Apply Changes'
  FindColumnToAdd: 'Add a Column'
  AddColumn: """
    <% if (num < 1) { %>
      No columns chosen
    <% } else { %>
      Add <%= num %> new <%= pluralise('column', num) %>
    <% } %>
  """
  AddColumnToSortOrder: 'Sort by this column'
  NoChangesToApply: 'There are no changes to apply.'
  OrderVerb: 'Add / Remove / Re-Arrange'
  OrderTitle: 'Columns'
  SortVerb: 'Configure'
  SortTitle: 'Sort-Order'
  OnlyColsInView: 'Only show columns in the table:'
  SortingHelpTitle: 'What Columns Can I Sort by?'
  ViewTabTitle: 'Selected Columns'
  SortOrderTabTitle: 'Sort Order'
  CurrentView: 'Current Columns'
  CurrentViewHelp: 'Re-arrange or remove columns by dragging, or by using the buttons'
  CurrentSortOrder: """
    <% if (oes.length) { %>
      <%= oes.length %> Order <%= pluralise('Elements', oes.length) %>
    <% } else { %>
      Not sorted.
    <% } %>
  """
  NoSortOrder: 'No sort order. Drop columns here to sort the table.'
  RemoveOrderElement: 'Remove this column from the sort-order'
  CurrentSortOrderHelp: """
    Re-arrange, add or remove columns. The full set of available
    columns is listed below.
  """
  ColumnsSelected: """
    <%= columns.length %> <%= pluralise("Column", columns.length) %>
    Selected<% if (removed) { %>, <%= removed %> Removed<% } %>
  """
  ChooseAPathFrom: 'Choose a path from <%= root %>'
  RemoveColumn: 'Remove this column'
  MoveUp: 'Move this column up'
  MoveDown: 'Move this column down'
  ColumnWillBeRemoved: 'This column will be removed'
  RestoreColumn: 'Add this column back to the table'
  ChangeDirection: 'Change sort direction'
  CurrentDirection: """
    Sorted in
    <%= (dir === 'DESC') ? 'reverse' : void 0 %>
    <%= numeric ? 'numerical' : 'alphabetical' %>
    order.
  """
  ManageColumns: 'Manage Columns'
  ManageColumnsShort: 'Columns'

