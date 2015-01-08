Constraints = require '../constraints'

module.exports = class SingleColumnConstraints extends Constraints

  getConAdder: -> null #-> new SingleConstraintAdder?

  getConstraints: ->
    view = @model.get 'path'
    (c for c in @query.constraints when c.path.match view)

