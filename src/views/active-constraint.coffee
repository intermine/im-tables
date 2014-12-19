_ = require 'underscore'
$ = require 'jquery'
fs = require 'fs'

{Promise} = require 'es6-promise'
{Query, Model} = require 'imjs'

# Support
Messages = require '../messages'
Icons = require '../icons'
Options = require '../options'
View = require '../core-view'

ConstraintSummary = require './constraint-summary'
ConstraintEditor = require './constraint-editor'

html = fs.readFileSync __dirname + '/../templates/active-constraint.html', 'utf8'

# It is very important that the ValuePlaceholder get set to the appropriate mine value.
Messages.set
  'conbuilder.Add': 'Add constraint'
  'conbuilder.Update': 'Update'
  'conbuilder.Cancel': 'Cancel'
  'conbuilder.Remove': 'Remove'
  'conbuilder.NotEditable': 'This constraint is not editable'
  'conbuilder.ValuePlaceholder': 'David*'
  'conbuilder.ExtraPlaceholder': 'Wernham-Hogg'
  'conbuilder.ExtraLabel': 'in'
  'conbuilder.IsA': 'is a'
  'conbuilder.NoValue': 'No value selected. Please enter a value.'
  'conbuilder.NoOperator': 'No operator selected. Please choose an operator.'
  'conbuilder.BadLoop': 'The selected path is not in the query.'
  'conbuilder.NaN': 'The value provided is not a number.'
  'conbuilder.Duplicate': 'This constraint is already on the query'
  'conbuilder.TooManySuggestions': 'We cannot show you all the possible values'
  'conbuilder.NoSuitableLists': 'No lists of this type are available'
  'conbuilder.NoSuitableLoops': 'No suitable loop paths were found'

aeql = (xs, ys) ->
  if not xs and not ys
    return true
  if not xs or not ys
    return false
  [shorter, longer] = _.sortBy [xs, ys], (a) -> a.length
  _.all longer, (x) -> x in shorter

basicEql = (a, b) ->
  return a is b unless (a and b)
  keys = _.union.apply _, [a, b].map _.keys
  same = true
  for k in keys
    [va, vb] = (x[k] for x in [a, b])
    same and= (if _.isArray va then aeql va, vb else va is vb)
  return same

# Composite view with a summary, and controls for editing the constraint.
module.exports = class ActiveConstraint extends View

  tagName: "div"

  className: "im-constraint row-fluid"

  initialize: ({@query, @constraint}) ->
    super
    # Model is the state of the constraint, with the path promoted to a full object.
    @model.set @constraint

    @state.set editing: false
    @listenTo @state, 'change:editing', @toggleEditor

    @listenTo @model, 'change:type', @setTypeName
    @listenTo @model, 'change:path', @setDisplayName

    # Declare rendering dependency on messages and icons.
    @listenTo Messages, 'change', @reRender
    @listenTo Icons, 'change', @reRender

    @listenTo @model, 'cancel', @cancelEditing
    @listenTo @model, 'apply', @applyChanges
    
    try
      @model.set path: @query.getPathInfo @constraint.path
    catch e
      @model.set error: e
      @state.set editing: true

    @setTypeName()

  setDisplayName: ->
    @model.get('path').getDisplayName (error, displayName) =>
      @model.set {error, displayName}
      if error?
        # Could have been caused by type constraints. Start listening.
        @listenToOnce @query, 'change:constraints', =>
          @model.set path: @query.getPathInfo @constraint.path
          @setDisplayName()

  cancelEditing: ->
    console.debug 'cancelling editing'
    @state.set editing: false
    @model.set _.omit @constraint, 'path'
    @model.set error: null

  toggleEditing: ->
    if @state.get('editing')
      @cancelEditing()
    else
      @state.set editing: true

  setTypeName: ->
    type = @model.get 'type'
    if not type?
      @model.unset 'typeName'
    else
      try
        @query.model.makePath(type)
              .getDisplayName (error, typeName) => @model.set {error, typeName}
      catch e # bad path most likely.
        @model.set error: e, typeName: type

  events: ->
    'click .im-edit': 'toggleEditing'
    'click .im-remove-constraint': 'removeConstraint'

  IS_BLANK = /^\s*$/

  getLoopProblem: (con) ->
    problem = try
      @query.getPathInfo(con.value)
      null
    catch e
      'BadLoop'
    return problem

  getValueProblem: (con) ->
    {path, op, value} = con
    console.debug con
    if not value? or (IS_BLANK.test value)
      return 'NoValue'

    if path.getType() in Model.NUMERIC_TYPES and (_.isNaN 1 * value)
      return 'NaN'

    return null

  getProblem: (con) ->
    if con.type?
      return null # Using a select list - cannot be wrong

    if not con.op or IS_BLANK.test con.op # No operator.
      return 'NoOperator'

    if con.path.isReference() and con.op in ['=', '!=']
      return @getLoopProblem con

    if con.op in Query.ATTRIBUTE_VALUE_OPS.concat(Query.REFERENCE_OPS)
      return @getValueProblem con

    if @isDuplicate con
      return 'Duplicate'

    return null

  isDuplicate: (con) -> _.any @query.constraints, _.partial basicEql, con

  setError: (key) ->
    msg = Messages.get "conbuilder.#{ key }"
    @model.set error: msg

  applyChanges: (con) ->
    problem = @getProblem con
    if problem?
      return @setError problem

    @state.set editing: false

    @removeConstraint(null, silently = true)

    if con.values? and not con.values.length
      # Empty multi-value constraint - treat as removal, and trigger the previously
      # suppressed change event.
      @query.trigger "change:constraints"
    else
      console.debug 'Adding constraint'
      con.path = con.path.toString()
      @query.addConstraint con
      @constraint = con
      @model.unset 'new'

  # Used both by buttons for removal, and by the code that applies the changes.
  removeConstraint: (e, silently = false) ->
    e?.preventDefault()
    e?.stopPropagation()
    unless @model.get 'new'
      @query.removeConstraint @constraint, silently
    if e? # This is real removal - no point hanging about.
      @remove()

  getData: ->
    messages = Messages
    icons = Icons
    con = @model.toJSON()
    {icons, messages, con}

  template: _.template html, variable: 'data'

  toggleEditor: ->
    if @state.get('editing') and @rendered
      opts = {@model, @query}
      @renderChild 'editor', (new ConstraintEditor opts), @$ '.im-constraint-editor'
    else
      @removeChild 'editor'

  renderSummary: ->
    opts = {@model}
    @renderChild 'summary', (new ConstraintSummary opts), @$ '.im-con-overview'

  render: ->
    super
    @renderSummary()
    @toggleEditor()
    this
