/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let PathSet;
const UniqItems = require('./uniq-items');
const Backbone = require('backbone');

// Differs in terms of the definition of containment, which is specialised for paths
module.exports = (PathSet = class PathSet extends UniqItems {

  paths() { return this.map(model => model.get('item')); }

  // True for X.y if X.y.z is open
  contains(path) { return this.any(model => path.equals(model.get('item'))); }

  toggle(path) { if (this.contains(path)) { return (this.remove(path)); } else { return (this.add(path)); } }

  remove(path) {
    if (path instanceof Backbone.Model) {
      return super.remove(...arguments);
    }

    const delendum = this.find(model => path.equals(model.get('item')));
    if (delendum != null) {
      return super.remove(delendum);
    }
  }
});

