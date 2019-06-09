_ = require 'underscore'

# A utility for creating a child CoreView from a parent in the common
# case where the child specifies what it wants in the parameters and
# optionalParameters properties which are named identically on the 
# parent. Other arguments can be provided as `args`.
# @param [CoreView] parent The parent view to read properties from
# @param [Constructor<CoreView>] Child The child view to instantiate
# @param [Object] args The optional extra arguments.
exports.createChild = (parent, Child, args = {}) ->
  params = (Child::parameters ? []).concat(Child::optionalParameters)
  props = _.extend (_.pick parent, params), args
  new Child props

