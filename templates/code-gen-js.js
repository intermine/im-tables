/* Install from npm: npm install imtables
 * This snippet assumes the presence on the page of an element like:
 * <div id="some-elem"></div>
 */
var imtables = require('imtables');

var selector = '#some-elem';
var service  = {root: '<%= service.root %>'};
var query    = <%= JSON.stringify(query, null, 2) %>;

imtables.loadQuery(
  selector, // Can also be an element, or a jQuery object.
  <%= JSON.stringify(page) %>, // May be null
  {service: service, query: query} // May be an imjs.Query
).then(
  function (table) { console.log('Table loaded', table); },
  function (error) { console.error('Could not load table', error); }
);
