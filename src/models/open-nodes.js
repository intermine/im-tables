// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let OpenNodes;
const Backbone = require('backbone');
const UniqItems = require('./uniq-items');

// True if a is b, or b is child of a
const descendsFrom = function(a, b) {
  if ((!(a != null ? a.equals : undefined)) || (!(b != null ? b.isRoot : undefined))) { return false; }
  while (!a.equals(b)) {
    // Now either keep going, or give up.
    if (b.isRoot()) { return false; } // nowhere to go
    b = b.getParent();
  }
  return true;
};

// Differs in terms of the definition of containment. If the node X.y.z is open, then
// X.y will return true for contains.
module.exports = (OpenNodes = class OpenNodes extends UniqItems {

  // True for X.y if X.y.z is open
  contains(path) {
    if (path instanceof Backbone.Model) {
      return super.contains(path);
    } else {
      return this.any(node => descendsFrom(path, node.get('item')));
    }
  }

  // Also removes sub-nodes.
  remove(path) {
    if ((path == null)) { return false; }
    if (path instanceof Backbone.Model) {
      super.remove(path);
    }

    const delenda = this.filter(node => descendsFrom(path, node.get('item')));
    return Array.from(delenda).map((delendum) =>
      super.remove(delendum));
  }
});
