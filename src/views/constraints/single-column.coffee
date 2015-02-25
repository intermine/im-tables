Constraints = require '../constraints'
SingleColumnConstraintAdder = require './single-column-adder'
ComposedColumnConstraintAdder = require './composed-column-adder'

# Consumes a HeaderModel
module.exports = class SingleColumnConstraints extends Constraints

  getConAdder: -> if @shouldShowAdder()
    {replaces, isComposed, outerJoined} = @model.attributes
    path = @model.pathInfo()
    if isComposed and replaces.length > 1
      new ComposedColumnConstraintAdder {@query, paths: replaces}
    else if outerJoined
      new ComposedColumnConstraintAdder {@query, paths: [path].concat(replaces)}
    else
      new SingleColumnConstraintAdder {@query, path: path}

  # Numeric paths can handle multiple constraints - others should just have one.
  shouldShowAdder: ->
    {numeric, isComposed, outerJoined} = @model.attributes
    numeric or isComposed or outerJoined or (not @getConstraints().length)

  getConstraints: ->
    view = @model.get 'path'
    (c for c in @query.constraints when c.path.match view)

