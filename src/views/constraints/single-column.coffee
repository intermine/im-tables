Constraints = require '../constraints'
SingleColumnConstraintAdder = require './single-column-adder'

# Consumes some kind of PathModel.
module.exports = class SingleColumnConstraints extends Constraints

  getConAdder: -> if @shouldShowAdder()
    new SingleColumnConstraintAdder {@query, path: @model.get 'path'}

  # Numeric paths can handle multiple constraints - others should just have one.
  shouldShowAdder: -> @model.get('numeric') or (not @getConstraints().length)

  getConstraints: ->
    view = @model.get 'path'
    (c for c in @query.constraints when c.path.match view)

