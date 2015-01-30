Constraints = require '../constraints'
SingleColumnConstraintAdder = require './single-column-adder'
ComposedColumnConstraintAdder = require './composed-column-adder'

# Consumes a HeaderModel
module.exports = class SingleColumnConstraints extends Constraints

  getConAdder: -> if @shouldShowAdder()
    if @model.get('isComposed')
      new ComposedColumnConstraintAdder {@query, paths: @model.get('replaces')}
    else
      new SingleColumnConstraintAdder {@query, path: @model.get 'path'}

  # Numeric paths can handle multiple constraints - others should just have one.
  shouldShowAdder: ->
    @model.get('numeric') or @model.get('isComposed') or (not @getConstraints().length)

  getConstraints: ->
    view = @model.get 'path'
    (c for c in @query.constraints when c.path.match view)

