/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Joins;
const _ = require('underscore');

const Collection = require('../core/collection');
const PathModel = require('./path');

class Join extends PathModel {

  defaults() { return _.extend(super.defaults(...arguments),
    {style: 'INNER'}); }

  constructor({path, style}) {
    super(path);
    if (style != null) { this.set({style}); }
  }
}

module.exports = (Joins = (function() {
  Joins = class Joins extends Collection {
    static initClass() {
  
      this.prototype.model = Join;
  
      this.prototype.comparator = 'displayName';
       // sort lexigraphically.
    }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this, 'change:displayName', this.sort);
    }

    getJoins() { return _.object(this.where({style: 'OUTER'}).map(m => [m.get('path'), m.get('style')])); }
  };
  Joins.initClass();
  return Joins;
})());

// Create an initialized collection from a query, effectively
// snap-shotting the join state.
Joins.fromQuery = function(query) {
  let path;
  const joins = new Joins;
  // Add the defined joins.
  for (let p in query.joins) {
    const style = query.joins[p];
    path = query.makePath(p);
    joins.add(new Join({style, path}));
  }
  // Add all the implicit joins.
  for (let n of Array.from(query.getQueryNodes())) {
    while (!n.isRoot()) {
      joins.add(new Join({path: n})); // no-op if already in the coll'n
      n = n.getParent();
    }
  }
  return joins;
};

