_ = require 'underscore'
CoreView = require '../../core-view'
PathModel = require '../../models/path'
Templates = require '../../templates'
Messages = require '../../messages'
ConstraintAdder = require '../constraint-adder'
AdderButton = require './column-adder-button'

require '../../messages/constraints'

OPTS_SEL = '.im-constraint-adder-options'

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


