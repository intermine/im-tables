_ = require 'underscore'

CoreView = require '../core-view'
Templates = require '../templates'

ConstraintAdder = require './constraint-adder'
ActiveConstraint = require './active-constraint'

require '../messages/constraints'

module.exports = class Constraints extends CoreView

  className: "im-constraints"

  initialize: ({@query}) ->
    super
    @listenTo @query, "change:constraints", @reRender

  getData: -> _.extend super, constraints: @getConstraints()

  events: -> click: (e) -> e?.stopPropagation()

  template: Templates.templateFromParts ['constraints-heading', 'active-constraints']

  postRender: ->
    container = @$ '.im-active-constraints'

    for constraint, i in @getConstraints()
      @renderChild "con_#{ i }", (new ActiveConstraint {@query, constraint}), container

    @renderChild 'conAdder', @getConAdder()

  getConstraints: -> @query.constraints.slice()

  getConAdder: -> new ConstraintAdder {@query}

