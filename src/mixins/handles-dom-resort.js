/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Mixin for CoreView - requires @children

const _ = require('underscore');

// Sort (at the model level) a collection of children
// that have been sorted on the DOM level (via sortable
// or some such).
//
// This assumes that setting 'index' on each model is sufficient
// to restore order to the world.
exports.setChildIndices = function(idFn, pos, collName) {
  if (pos == null) { pos = 'top'; }
  if (collName == null) { collName = 'collection'; }
  const kids = this.children;
  const coll = this[collName];
  // For each model, find the view associated with it, if it exists.
  const views = _.compact(coll.map(model => kids[idFn(model)]));
  // Order the views by their position.
  const sorted = _.sortBy(views, v => v.el.getBoundingClientRect()[pos]);
  return (() => {
    const result = [];
    for (let i = 0; i < sorted.length; i++) {
      const v = sorted[i];
      result.push(v.model.set({index: i}));
    }
    return result;
  })();
};


