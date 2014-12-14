require('imtables/shim');

var imjs = require('imjs');

var Options = require('imtables/options');
var ActiveConstraint = require('imtables/views/active-constraint');

var root = 'http://www.flymine.org/query/service';

var flies = {
  select: ['commonName', 'taxonId'],
  from: 'Organism',
  where: {genus: 'Drosophila'}
};

var conn = imjs.Service.connect({root: root});

conn.query(flies)
    .then(renderQuery)
    .then(null, console.error.bind(console, 'Could not render query'));

function renderQuery (query) {
  var constraint = query.constraints[0];
  var view = new ActiveConstraint({
    query: query,
    constraint: constraint
  });
  view.setElement(document.querySelector('#demo'));
  view.render();
}
