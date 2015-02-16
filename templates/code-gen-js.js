/* Install from npm: npm install imtables
 * This snippet assumes the presence on the page of an element like:
 * <div id="some-elem"></div>
 */
var imtables = require('imtables');

var selector = '#some-elem';
var page     = <%= JSON.stringify(page) %>;
var service  = {root: "<%= service.root %>"};
var query    = <%= JSON.stringify(query, null, 2) %>;

imtables.loadQuery('#some-elem', page, {service: service, query: query});
        .then(
            function (table) { console.log('Table loaded', table); },
            function (error) { console.error('Could not load table', error); }
        );
