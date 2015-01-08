Constraints = require '../constraints'

module.exports = class SingleColumnConstraints extends Constraints

  getConAdder: -> null #-> new SingleConstraintAdder(@query, @view)

  getConstraints: -> (c for c in @query.constraints when c.path.match @view)

