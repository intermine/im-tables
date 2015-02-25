_ = require 'underscore'
CoreView = require '../../core-view'
PathModel = require '../../models/path'
Templates = require '../../templates'
Messages = require '../../messages'
ConstraintAdder = require '../constraint-adder'
AdderButton = require './column-adder-button'

require '../../messages/constraints'

OPTS_SEL = '.im-constraint-adder-options'

class DropdownButtonGrp extends CoreView

  className: 'btn-group'

  parameters: ['main', 'options']

  initState: -> @state.set open: false

  stateEvents: ->
    'change:open': @toggleOpen

  toggleOpen: -> @$el.toggleClass 'open', @state.get('open')

  ICONS: 'NONE'

  postRender: ->
    @toggleOpen()
    @renderChild 'main', @main
    @renderChild 'toggle', new Toggle state: @state
    ul = document.createElement 'ul'
    ul.className = 'dropdown-menu'
    for kid, i in @options
      @renderChild i, kid, ul
    @$el.append ul

class Toggle extends CoreView

  tagName: 'button'

  className: 'btn btn-primary dropdown-toggle'

  ICONS: 'NONE'

  template: _.template """
    <span class="caret"></span>
    <span class="sr-only"><%- Messages.getText('constraints.OtherPaths') %></span>
  """

  events: -> click: -> @state.toggle 'open'

class Option extends AdderButton

  tagName: 'li'

  className: ''

  template: -> """<a>#{ super }</a>"""

module.exports = class ComposedColumnConstraintAdder extends ConstraintAdder

  parameters: ['query', 'paths']

  onChosen: (path) -> @model.set constraint: {path}

  renderOptions: -> # nothing to do here.

  showTree: ->
    [p, ps...] = @paths
    mainButton = new AdderButton hideType: true, model: (new PathModel p)
    opts = for p_ in ps
      new Option hideType: true, model: (new PathModel p_)
    grp = new DropdownButtonGrp main: mainButton, options: opts

    for b in [mainButton, opts...]
      @listenTo b, 'chosen', @onChosen

    @renderChild 'tree', grp, @$ OPTS_SEL

