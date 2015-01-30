_ = require 'underscore'
CoreView = require '../../core-view'
PathModel = require '../../models/path'
Templates = require '../../templates'
Messages = require '../../messages'
ConstraintAdder = require '../constraint-adder'
AdderButton = require './column-adder-button'

require '../../messages/constraints'

OPTS_SEL = '.im-constraint-adder-options'

class ButtonGrp extends CoreView

  className: 'btn-group'

  parameters: ['kids']

  postRender: -> for kid, i in @kids
    @renderChild i, kid

module.exports = class ComposedColumnConstraintAdder extends ConstraintAdder

  parameters: ['query', 'paths']

  onChosen: (path) ->
    @model.set constraint: {path}
    @hideTree()
    @renderConstraintEditor()

  renderOptions: -> # nothing to do here.

  showTree: ->
    btns = (new AdderButton {hideType: true, model: (new PathModel p)} for p in @paths)
    for b in btns
      @listenTo b, 'chosen', @onChosen
    grp = new ButtonGrp kids: btns
    @renderChild 'tree', grp, @$ OPTS_SEL

