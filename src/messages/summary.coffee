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
  OnlyOne: 'There is only one value: <%= item %>'
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
  Total: """
    <% if (filtered) { %>(filtered from <%= formatNumber(total) %>)<% } %>
  """
