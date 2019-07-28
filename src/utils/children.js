const _ = require('underscore');

// A utility for creating a child CoreView from a parent in the common
// case where the child specifies what it wants in the parameters and
// optionalParameters properties which are named identically on the 
// parent. Other arguments can be provided as `args`.
// @param [CoreView] parent The parent view to read properties from
// @param [Constructor<CoreView>] Child The child view to instantiate
// @param [Object] args The optional extra arguments.
exports.createChild = function(parent, Child, args) {
  if (args == null) { args = {}; }
  const params = (Child.prototype.parameters != null ? Child.prototype.parameters : []).concat(Child.prototype.optionalParameters);
  const props = _.extend((_.pick(parent, params)), args);
  return new Child(props);
};

