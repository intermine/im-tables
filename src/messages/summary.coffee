Messages = require '../messages'

Messages.setWithPrefix 'summary',
  Got: '<% if (available > got) { %>Showing <%= formatNumber(got) %> of<% } %>'
  Max: 'Maximum'
  Min: 'Minimum'
  Bucket: "<%= range.min %> to <%= range.max %>: <%= count %> values"
  Count: 'Count'
  Item: 'Item'
  Average: 'Average'
  StdDev: 'Standard Deviation'
  OnlyOne: """
    There is only one <%- names.typeName %> <%- names.endName %>:
    <strong><%- item.item %></strong>, which occurs
    <strong>
      <% if (item.count === 1) { %>
        once
      <% } else if (item.count === 2) { %>
        twice
      <% } else { %>
        <%- formatNumber(item.count) %> times
      <% } %>
    </strong>
  """
  NumericDistribution: 'Showing distribution of <%= formatNumber(n) %>'
  FilterValuesPlaceholder: 'Filter values'
  DownloadData: 'Download column summary'
  DownloadFormat: 'As'
  MoreItems: 'Load more items'
  Include: 'Restrict table to matching rows'
  Exclude: 'Exclude matching rows from table'
  Reset: 'Reset selection'
  Toggle: 'Toggle selection'
  SelectFilter: 'Select filter type'
  FacetBar: 'rgba(206, 210, 222, <%= opacity %>)' # The colour of facet bars.
  NoResults: 'No results for <%= path %>'
  SelectedCount: """
    <%= isApprox ? "ca. " : void 0 %><%= formatNumber(selectedCount) %>
    <%= pluralise('Item', selectedCount) %> Selected
  """
  Total: """
    <% if (filtered) { %>(filtered from <%= formatNumber(total) %>)<% } %>
  """
