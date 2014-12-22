_ = require 'underscore'

Modal = require './modal'
ConstraintAdder = require './constraint-adder'
Templates = require '../templates'

# Very simple dialogue that just wraps a ConstraintAdder
module.exports = class ExportDialogue extends Modal

  className: -> 'im-export-dialogue ' + super

  initialize: ({@query}) ->
    super

  template: Templates.template 'export_dialogue'

  render: ->
    super
    this
