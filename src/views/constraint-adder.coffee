_ = require 'underscore'
fs = require 'fs'

# Support
Messages = require '../messages'
View = require '../core-view'
UniqItems = require '../models/uniq-items'

# Sub-views
NewConstraint = require './new-constraint'
PathChooser = require './path-chooser'

html = fs.readFileSync __dirname + '/../templates/constraint-adder.mtpl', 'utf8'
options_html = fs.readFileSync __dirname + '/../templates/constraint-adder-options.mtpl', 'utf8'

Messages.set
  'constraints.BrowseForColumn': 'Browse for Column'
  'constraints.AddANewFilter': 'Add a new filter'
  'constraints.Choose': 'Choose'
  'constraints.Filter': 'Filter'
  'columns.CollapseAll': 'Collapse columns'
  'columns.AllowRevRef': 'Allow reverse references'

# Encapsulate the bits we want to rerender in their own view.
class ConstraintAdderOptions extends View

  initialize: ({@openNodes, @chosenPaths}) ->
    @listenTo @model, 'change', @reRender
    @listenTo @openNodes, 'add remove reset', @reRender
    @listenTo @chosenPaths, 'add remove reset', @reRender

  getData: ->
    anyNodesOpen = @openNodes.size()
    anyNodeChosen = @chosenPaths.size()
    _.extend {anyNodesOpen, anyNodeChosen}, super

  template: _.template options_html

  events: ->
    'click .im-collapser': 'collapseBranches'
    'change .im-allow-rev-ref': 'toggleReverseRefs'
    'click .im-choose': 'toggleShowTree'
    'click .im-approve': 'triggerApproval'

  collapseBranches: -> @openNodes.reset()

  toggleShowTree: -> @model.toggle 'showTree'

  toggleReverseRefs: -> @model.toggle 'allowRevRefs'

  setConstraint: -> @model.trigger 'approved'

module.exports = class ConstraintAdder extends View

  tagName: 'div'

  className: 'im-constraint-adder row-fluid'

  initialize: ({@query}) ->
    super
    @model.set
      root: @query.getPathInfo(@query.root) # Should never change.
      showTree: false           # Should we be showing the tree?
      allowRevRefs: false       # Can we expand reverse references?
      canSelectReferences: true # Can we select references?
      multiSelect: false        # Can we select multiple paths?

    # These require paths to be equal by ===, make sure that happens.
    # it might need changing otherwise to include a comparator fn.
    @chosenPaths = new UniqItems
    @openNodes = new UniqItems @query.getViewNodes() # Open by default
    @listenTo @model, 'change:showTree', @toggleTree
    @listenTo @query, 'change:constraints', @remove # our job is done
    @listenTo @model, 'approved', @handleApproval
    @listenTo @model, 'change:constraint', @onChangeConstraint

  getTreeRoot: -> @model.get 'root'

  handleApproval: ->
    [chosen] = @chosenPaths.toJSON()
    if chosen?
      current = @model.get 'constraint'
      newPath = chosen.toString()
      if current?.path isnt newPath
        constraint = path: newPath
        @model.set {constraint}
        @query.trigger 'editing-constraint', constraint # likely not necessary - remove?
    else
      console.debug 'nothing chosen'
      @model.unset 'constraint'

  onChangeConstraint: ->
    constraint = @model.has 'constraint'
    if constraint?
      @model.set showTree: false
      @renderChild 'con', (NewConstraint {@query, constraint}), @$ '.im-new-constraint'
    else
      @removeChild 'con'

  toggleTree: ->
    if @model.get('showTree')
      @showTree()
    else
      @hideTree()

  hideTree: ->
    @trigger 'resetting:tree'
    @removeChild 'tree'

  showTree: (e) =>
    @trigger 'showing:tree'
    pathFinder = new PathChooser {@model, @query, @chosenPaths, @openNodes, trail: []}
    @renderChild 'tree', pathFinder, @$ '.im-path-finder'
    # The code below is probably not necessary.
    # pathFinder.$el.show().css top: @$el.height() # I do not like this...

  template: -> html # our template has no variables.

  renderOptions: ->
    opts = {@model, @openNodes, @chosenPaths}
    @renderChild 'opts', (new ConstraintAdderOptions opts), @$ '.im-constraint-adder-options'

  render: ->
    super
    @renderOptions()
    @toggleTree() # respect the open status.
    this

