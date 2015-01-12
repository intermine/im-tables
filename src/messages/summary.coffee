module.exports =
  'summary.Got': '<% if (available > got) { %>Showing <%= formatNumber(got) %> of<% } %>'
  'summary.Max': 'Maximum'
  'summary.Min': 'Minimum'
  'summary.Average': 'Average'
  'summary.StdDev': 'Standard Deviation'
  'summary.OnlyOne': 'There is only one value: <%= item %>'
  'summary.Total': """
    <% if (filtered) { %>(filtered from <%= formatNumber(total) %>)<% } %>
  """
