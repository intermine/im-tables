module.exports =
  'summary.Got': '<% if (available > got) { %>Showing <%= formatNumber(got) %> of<% } %>'
  'summary.Total': """
    <% if (filtered) { %>(filtered from <%= formatNumber(total) %>)<% } %>
  """
