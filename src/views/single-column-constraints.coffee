{Constraints} = require './constraints'

class exports.SingleColumnConstraints extends Constraints
    initialize: (query, @view) -> super(query)

    getConAdder: -> null #-> new SingleConstraintAdder(@query, @view)

    getConstraints: -> c for c in @query.constraints when (c.path.match @view)
