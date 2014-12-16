'use strict';

require('imtables/shim');
var $ = require('jquery');
var imjs = require('imjs');
var View = require('imtables/core-view');
var Options = require('imtables/options');
var ActiveConstraint = require('imtables/views/active-constraint');

var root = 'http://localhost:8080/intermine-demo';
var conn = imjs.Service.connect({root: root});

var Counter = View.extend({

  initialize: function (opts) {
    View.prototype.initialize.apply(this, arguments);
    this.query = opts.query;
    this.model.set({count: 0});
    this.listenTo(this.query, 'change:constraints', this.updateCount);
    this.listenTo(this.model, 'change', this.render);
    this.updateCount();
  },

  updateCount: function () {
    var self = this;
    this.query.count().then(function (c) {
      self.model.set({count: c});
    });
  },

  render: function () {
    var name = this.query.name;
    var count = this.model.get('count');
    this.$el.empty().text(name + ' (' + count + ' rows)');
  }
});

var queries = [
  {
    name: 'attributes',
    select: ['name', 'department.name', 'department.manager.name'],
    from: 'Employee',
    where: [
      ['name', '=', 'd*'],
      ['age', '>', 35],
      ['fullTime', '=', true]
    ]
  },
  {
    name: 'multivalue',
    select: ['name', 'department.name', 'department.manager.name'],
    from: 'Employee',
    where: [
      ['name', 'ONE OF', ['Anne', 'Brenda', 'Carol']]
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
        .then(renderQuery.bind(null, h2, div))
        .then(null, console.error.bind(console, 'Could not render query'));
  });

}

function renderQuery (heading, container, query) {
  var counter = new Counter({el: heading, query: query});
  counter.render();
  query.constraints.forEach(function (constraint) {
    var view = new ActiveConstraint({
      query: query,
      constraint: constraint
    });
    view.$el.appendTo(container);
    view.render();
  });
}
