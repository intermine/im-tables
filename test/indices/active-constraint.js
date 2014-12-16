'use strict';

require('imtables/shim');
var $ = require('jquery');
var imjs = require('imjs');
var Options = require('imtables/options');
var ActiveConstraint = require('imtables/views/active-constraint');

var root = 'http://localhost:8080/intermine-demo';
var conn = imjs.Service.connect({root: root});
var queries = [
  {
    name: 'attributes',
    select: ['name', 'department.name', 'department.manager.name'],
    from: 'Employee',
    where: [
      ['name', '=', 'd*'],
      ['age', '>', 35]
    ]
  },
  {
    name: 'lookup',
    select: ['name', 'department.name', 'department.manager.name'],
    from: 'Employee',
    where: [
      ['department.manager', 'lookup', 'anne, brenda, carol']
    ]
  },
  {
    name: 'lists',
    select: ['name', 'department.name', 'department.manager.name'],
    from: 'Employee',
    where: [
      ['Employee', 'IN', 'My favourite employees']
    ]
  }
]

$(main);

function main () {
  var container = document.querySelector('#demo');
  queries.forEach(function (q) {
    var div = document.createElement('div');
    var h2 = document.createElement('h2');

    container.appendChild(div);
    h2.innerHTML = q.name
    div.appendChild(h2);

    conn.query(q)
        .then(renderQuery.bind(null, div))
        .then(null, console.error.bind(console, 'Could not render query'));
  });

}

function renderQuery (container, query) {
  query.constraints.forEach(function (constraint) {
    var view = new ActiveConstraint({
      query: query,
      constraint: constraint
    });
    view.$el.appendTo(container);
    view.render();
  });
}
