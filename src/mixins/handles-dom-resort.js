# Mixin for CoreView - requires @children

_ = require 'underscore'

# Sort (at the model level) a collection of children
# that have been sorted on the DOM level (via sortable
# or some such).
#
# This assumes that setting 'index' on each model is sufficient
# to restore order to the world.
exports.setChildIndices = (idFn, pos = 'top', collName = 'collection') ->
  kids = @children
  coll = @[collName]
  # For each model, find the view associated with it, if it exists.
  views = _.compact coll.map (model) -> kids[idFn model]
  # Order the views by their position.
  sorted = _.sortBy views, (v) -> v.el.getBoundingClientRect()[pos]
  for v, i in sorted
    v.model.set index: i


