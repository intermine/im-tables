<% if (asHTML) { %>
<!-- The Element we will target -->
<div id="some-elem"></div>
<!-- The imtables source -->
<script src="<%= imtablesJS %>" charset="UTF-8"></script>
<link rel="stylesheet" href="<%= imtablesCSS %>">
<script>
<% } %>
<% if (!asHTML) { %>
/* Install from npm: npm install im-tables
 * This snippet assumes the presence on the page of an element like:
 * <div id="some-elem"></div>
 */
var imtables = require('im-tables');
<% } %>

var selector = '#some-elem';
var service  = {root: '<%= service.root %>'};
var query    = <%= JSON.stringify(query, null, 2) %>;

imtables.loadTable(
  selector, // Can also be an element, or a jQuery object.
  <%= JSON.stringify(page) %>, // May be null
  {service: service, query: query} // May be an imjs.Query
).then(
  function (table) { console.log('Table loaded', table); },
  function (error) { console.error('Could not load table', error); }
);
<% if (asHTML) { %>
</script>
<% } %>
