require('imtables/shim');

var imjs = require('imjs');

var Options = require('imtables/options');
var ActiveConstraint = require('imtables/views/active-constraint');

var root = 'http://localhost:8080/intermine-demo';

var flies = {
  select: ['name', 'department.name'],
  from: 'Employee',
  where: [
    ['name', '=', 'd*'],
    ['age', '>', 35]
  ]
};

var conn = imjs.Service.connect({root: root});

conn.query(flies)
    .then(renderQuery)
    .then(null, console.error.bind(console, 'Could not render query'));

function renderQuery (query) {
  var container = document.querySelector('#demo');
  query.constraints.forEach(function (constraint) {
    var view = new ActiveConstraint({
      query: query,
      constraint: constraint
    });
    view.$el.appendTo(container);
    view.render();
  });
}
