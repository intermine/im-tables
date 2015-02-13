Messages = require '../messages'

Messages.setWithPrefix 'table',
  Building: 'Loading Table ...'
  OverlayText: 'Requesting data...'
  Empty: 'No Results'
  EmptyWhy: 'This query returns no results. You may wish to change its filters'

Messages.setWithPrefix 'table.lg',
  ShowingAll: 'Showing all <%= formatNumber(count) %> rows'
  ShowingRange: """
    Showing <%= formatNumber(first) %> to <%= formatNumber(last) %>
    of <%= formatNumber(count) %> <%= pluralise("row", count) %>
  """

Messages.setWithPrefix 'table.md',
  ShowingAll: 'All <%= formatNumber(count) %> rows'
  ShowingRange: """
    <%= formatNumber(first) %> to <%= formatNumber(last) %>
    of <%= formatNumber(count) %>
  """

Messages.setWithPrefix 'table.sm',
  ShowingAll: 'All rows'
  ShowingRange: """
    <%= formatNumber(first) %> to <%= formatNumber(last) %>
  """

Messages.setWithPrefix 'table.xs',
  ShowingAll: 'All rows'
  ShowingRange: """
    <%= formatNumber(first) %> to <%= formatNumber(last) %>
  """
