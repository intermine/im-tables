Messages = require '../messages'

Messages.setWithPrefix 'summary',
  Got: '<% if (available > got) { %>Showing <%= formatNumber(got) %> of<% } %>'
  Max: 'Maximum'
  Min: 'Minimum'
  Bucket: "<%= range.min %> to <%= range.max %>: <%= count %> values"
  Average: 'Average'
  StdDev: 'Standard Deviation'
  OnlyOne: 'There is only one value: <%= item %>'
  Total: """
    <% if (filtered) { %>(filtered from <%= formatNumber(total) %>)<% } %>
  """
