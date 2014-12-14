_ = require 'underscore'

# Support
Messages = require '../messages'
Icons = require '../icons'
View = require '../core-view'
UniqItems = require '../models/uniq-items'

# Sub-views
NewConstraint = require './new-constraint'
PathChooser = require './path-chooser'

{Query} = require 'imjs'

Messages.set
  'constraints.BrowseForColumn': 'Browse for Column'
  'constraints.AddANewFilter': 'Add a new filter'
  'constraints.Choose': 'Choose'
  'constraints.Filter': 'Filter'

### FIXME - this section is needed somewhere, work out where.
pos = (substr) -> _.memoize (str) -> str.toLowerCase().indexOf substr
pathLen = _.memoize (str) -> str.split(".").length

# FIXME Needs to be wrapped in a function
CONSTRAINT_ADDER_HTML = _.template """
  <input type="text"
         placeholder="<%= messages.getText('constraints.AddANewFilter') %>"
         class="im-constraint-adder span9">
  <button disabled class="btn btn-primary span2" type="submit">
    <%= messages.getText('constraints.Filter') %>
  </button>
"""
###

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
    # it might need changing otherwise.
    @chosenPaths = new UniqItems
    @openNodes = new UniqItems @query.getViewNodes() # Open by default
    @listenTo @model, 'change:showTree', @toggleTree
    @listenTo @chosenPaths, 'add remove reset', @handleChoice
    @listenTo @query, 'change:constraints', @remove # our job is done

  getTreeRoot: -> @model.get 'root'

  events: ->
    'submit': 'handleSubmission'
    'click .im-collapser': 'collapseBranches'
    'change .im-allow-rev-ref': 'toggleReverseRefs'
    'click .im-choose': 'toggleShowTree'
    'click .im-approve': 'handleSubmission'

  collapseBranches: -> @openNodes.reset()

  toggleShowTree: -> @model.toggle 'showTree'

  toggleReverseRefs: -> @model.toggle 'allowRevRefs'

  handleSubmission: (e) ->
    e?.preventDefault()
    e?.stopPropagation()

    [chosen] = @chosenPaths.toJSON()
    if chosen?
      constraint = path: chosen.toString()
      @renderChild 'newcon', (new NewConstraint {@query, constraint}), @$ '.new-constraint'
      @$('.btn-primary').fadeOut('fast') # Only add one constraint at a time...
      @removeChild 'pathfinder'
      @query.trigger 'editing-constraint'
    else
      console.debug "Nothing chosen"

  handleChoice: ->
    @$('.im-approve').fadeToggle @chosenPaths.size() > 0

  isDisabled: (path) -> false

  setShowTree: (showTree) -> @model.set {showTree}

  toggleTree: ->
    if @model.get('showTree')
      @showTree()
    else
      @hideTree()

  hideTree: ->
    @trigger 'resetting:tree'
    @$('.im-tree-option').addClass 'hidden'
    @removeChild 'pathfinder'

  showTree: (e) =>
    @trigger 'showing:tree'
    @removeChild 'pathfinder'
    @$('.im-tree-option').removeClass 'hidden'
    pathFinder = new PathChooser {@model, @query, @chosenPaths, @openNodes, trail: []}
    @renderChild 'pathfinder', pathFinder, @$ '.path-finder'
    pathFinder.$el.show().css top: @$el.height() # I do not like this...

  VALUE_OPS = Query.ATTRIBUTE_VALUE_OPS.concat(Query.REFERENCE_OPS)

  # isValid: () -> is this needed? Where is it called?
  #   if @newCon?
  #     if not @newCon.con.has('op')
  #       return false
  #     if @newCon.con.get('op') in VALUE_OPS
  #       return @newCon.con.has('value')
  #     if @newCon.con.get('op') in intermine.Query.MULTIVALUE_OPS
  #         return @newCon.con.has('values')
  #     return true
  #   else
  #     return false

  getData: -> _.extend {messages: Messages, icons: Icons}, data

  template: _.template """
    <div>
      <button type="button" class="btn btn-chooser im-choose" data-toggle="button">
        <%= icons.icon('Tree') %>
        <span><%= messages.getMessage('constraints.BrowseForColumn') %></span>
      </button>
      <label class="im-tree-option hidden">
        <%- messages.get('columns.AllowRevRef') %>
        <input type="checkbox" class="im-allow-rev-ref">
      </label>
      <button class="btn im-collapser im-tree-option hidden" type="button" >
        <%- messages.get('columns.CollapseAll') %>
      </button>
      <button class="btn btn-primary im-approve" style="display:none">
        <%- messages.getMessage('constraints.Choose') %>
      </button>
    </div>
    <div class="path-finder"><div>
    <div class="new-constraint"></div>
  """

  render: ->
    super
    @toggleTree() # respect the open status.

