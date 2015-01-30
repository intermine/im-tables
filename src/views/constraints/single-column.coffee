Constraints = require '../constraints'
SingleColumnConstraintAdder = require './single-column-adder'

module.exports = class SingleColumnConstraints extends Constraints

  getConAdder: -> new SingleColumnConstraintAdder {@query, path: @model.get 'path'}

  getConstraints: ->
    view = @model.get 'path'
    (c for c in @query.constraints when c.path.match view)

