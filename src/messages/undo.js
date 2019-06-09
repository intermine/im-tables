const Messages = require('../messages');

Messages.setWithPrefix('undo', {
  StepTitle: `\
<% if (label === 'Initial') { %>
  Initial State
<% } else if (verb === 'Added') { %>
  <% if (label === 'sort order element') { %>
    Added <%= formatNumber(number) %> <%= pluralise('column', number) %> to the sort order
  <% } else if (label === 'column') { %>
    Selected <%= formatNumber(number) %> <%= pluralise('column', number) %>
  <% } else { %>
    Added <%= formatNumber(number) %> <%= pluralise(label, number) %>
  <% } %>
<% } else if (verb === 'Removed') { %>
  <% if (label === 'sort order element') { %>
    Removed <%= formatNumber(number) %> <%= pluralise('column', number) %> from the sort order
  <% } else if (label === 'column') { %>
    Unselected <%= formatNumber(number) %> <%= pluralise('column', number) %>
  <% } else { %>
    Removed <%= formatNumber(number) %> <%= pluralise(label, number) %>
  <% } %>
<% } else if (verb === 'Changed') { %>
  <% if (label === 'sort order element') { %>
    Changed sort order
  <% } else { %>
    Changed <%= pluralise(label, 2) %>
  <% } %>
<% } else if (verb === 'Rearranged') { %>
  Rearranged <%= pluralise(label, 2) %>
<% } else { %>
  !!!Cannot handle <%= verb %> <%= label %>!!!
<% } %>\
`,
  StepCount: `\
<%= formatNumber(count) %> <%= pluralise("row", count) %>\
`,
  RevertToState: 'Revert to this state',
  IsCurrentState: 'This is the current state',
  ViewCount: '<%= n %> <%= pluralise("column", n) %> selected',
  ConstraintCount: `\
<% if (n) { %>
  <%= n %> <%= pluralise('filter', n) %>
<% } else { %>
  No filters
<% } %>\
`,
  OrderElemCount: `\
<% if (n) { %>
  Sorted on <%= n %> <%= pluralise('column', n) %>
<% } else { %>
  Not sorted
<% } %>\
`,
  ShowAllStates: "Show <%= n %> hidden <%= pluralise('state', n) %>",
  ToggleTrivial: '<%= hideTrivial ? "Hiding" : "Hide" %> minor steps',
  ToggleTrivialTitle: '<%= hideTrivial ? "Hiding" : "Hide" %> steps that did not change the row count',
  Revision: 'no. <%= v %>',
  RevisionTitle: 'revision <%= v %>',
  MoreSteps: '<%= more %> more <%= pluralise("step", more) %>'
}
);

