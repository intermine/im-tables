_ = require 'underscore'
CoreView = require '../../core-view'
PathModel = require '../../models/path'
Templates = require '../../templates'
Messages = require '../../messages'
ConstraintAdder = require '../constraint-adder'

require '../../messages/constraints'

OPTS_SEL = '.im-constraint-adder-options'

class AdderButton extends CoreView
  
  tagName: 'button'

  className: 'btn btn-primary im-add-constraint'

  template: (data) -> _.escape Messages.getText 'constraints.AddConFor', data

  modelEvents: -> change: @reRender

module.exports = class SingleColumnConstraintAdder extends ConstraintAdder

  parameters: ['query', 'path']

  initialize: ->
    super
    constraint = path: @path
    @model.set {constraint}

  events: ->
    'click .im-add-constraint': @act
  
  act: ->
    @hideTree()
    @renderConstraintEditor()

  renderOptions: -> # nothing to do here.

  showTree: ->
    model = new PathModel @query.makePath @path
    button = new AdderButton {model}
    @renderChild 'tree', (new AdderButton {model}), @$ OPTS_SEL


