_ = require 'underscore'

# Support
Messages = require '../messages'
Templates = require '../templates'
View = require '../core-view'
CoreModel = require '../core-model'
PathSet = require '../models/path-set'
OpenNodes = require '../models/open-nodes'

# Sub-views
ConstraintAdderOptions = require './constraint-adder-options'
NewConstraint = require './new-constraint'
PathChooser = require './path-chooser'

# Text strings
Messages.set
  'constraints.BrowseForColumn': 'Browse for Column'
  'constraints.AddANewFilter': 'Add a new filter'
  'constraints.Choose': 'Choose'
  'constraints.Filter': 'Filter'
  'columns.CollapseAll': 'Collapse columns'
  'columns.AllowRevRef': 'Allow reverse references'

class ConstraintAdderModel extends CoreModel
  
  defaults: ->
    filter: null              # No filter by default, but in the model for templates.
    showTree: true            # Should we be showing the tree?
    allowRevRefs: false       # Can we expand reverse references?
    canSelectReferences: true # Can we select references?
    multiSelect: false        # Can we select multiple paths?

OPTIONS_SEL = '.im-constraint-adder-options'

module.exports = class ConstraintAdder extends View

  tagName: 'div'

  className: 'im-constraint-adder row-fluid'
  
  Model: ConstraintAdderModel

  initialize: ({@query, @buttonDelegate}) ->
    super
    @model.set
      root: @query.getPathInfo(@query.root) # Should never change.

    @chosenPaths = new PathSet
    @view = new PathSet(@query.makePath p for p in @query.views)
    @openNodes = new OpenNodes @query.getViewNodes() # Open by default
    @listenTo @query, 'change:constraints', @remove # our job is done

  modelEvents: ->
    approved: @handleApproval
    'change:showTree': @toggleTree
    'change:constraint': @onChangeConstraint

  getTreeRoot: -> @model.get 'root'

  handleApproval: ->
    [chosen] = @chosenPaths.toJSON()
    if chosen?
      current = @model.get 'constraint'
      newPath = chosen.toString()
      if current?.path isnt newPath
        constraint = path: newPath
        @model.set {constraint}
        # likely not necessary - remove? Tells containers which phase we are in.
        @query.trigger 'editing-constraint', constraint
      else # Path hasn't changed - go back to the constraint.
        @onChangeConstraint()
    else
      console.debug 'nothing chosen'
      @model.unset 'constraint'

  renderConstraintEditor: ->
    constraint = @model.get 'constraint'
    editor = new NewConstraint {@buttonDelegate, @query, constraint}
    @renderChild 'con', editor, @$ '.im-new-constraint'
    @listenTo editor, 'remove', -> @model.set showTree: true

  onChangeConstraint: -> if @rendered
    if @model.get 'constraint'
      @model.set showTree: false
      @renderConstraintEditor()
    else
      @removeChild 'con'

  toggleTree: ->
    if @model.get('showTree')
      @showTree()
    else
      @hideTree()

  hideTree: ->
    @trigger 'resetting:tree'
    @$('.im-path-finder').removeClass('open')
    @removeChild 'tree'

  showTree: (e) =>
    @trigger 'showing:tree'
    @removeChild 'con' # Either show the tree or the constraint editor, not both.
    pathFinder = new PathChooser {@model, @query, @chosenPaths, @openNodes, @view, trail: []}
    @$('.im-path-finder').addClass('open')
    @renderChild 'tree', pathFinder, @$ '.im-path-finder'

  template: Templates.template 'constraint_adder'

  renderOptions: ->
    opts = {@model, @openNodes, @chosenPaths, @query}
    @renderChild 'opts', (new ConstraintAdderOptions opts), @$ OPTIONS_SEL

  postRender: ->
    @renderOptions()
    @toggleTree() # respect the open status.

