Messages = require '../messages'

Messages.setWithPrefix 'undo',
  StepTitle: """
    <% if (label === 'Initial') { %>
      Initial State
    <% } else if (verb === 'Added') { %>
      Added <%= formatNumber(number) %> <%= pluralise(label, number) %>
    <% } else if (verb === 'Changed') { %>
      Changed <%= label %>
    <% } else { %>
      !!!Cannot handle <%= verb %> <%= label %>!!!
    <% } %>
  """
  StepCount: """
    <%= formatNumber(count) %> <%= pluralise("row", count) %>
  """
  RevertToState: 'Revert to this state'
  IsCurrentState: 'This is the current state'
  ViewCount: '<%= n %> <%= pluralise("column", n) %> selected'
  OrderElemCount: """
    <% if (n) { %>
      Sorted on <%= n %> <%= pluralise('column', n) %>
    <% } else { %>
      Not sorted
    <% } %>
  """

