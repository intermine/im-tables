_ = require 'underscore'
fs = require 'fs'
{Promise} = require 'es6-promise'

mixOf = require '../mix-of'
View = require '../core-view'
Options = require '../options'
HasTypeaheads = require '../mixins/has-typeaheads'
{IS_BLANK} = require '../patterns'

options_html = fs.readFileSync __dirname + '/../templates/constraint-adder-options.mtpl', 'utf8'

# The control elements of a constraint adder.
module.exports = class ConstraintAdderOptions extends mixOf View, HasTypeaheads

  className: 'row'

  initialize: ({@query, @openNodes, @chosenPaths}) ->
    super
    @state.set chosen: [] # default value.
    @listenTo @model, 'change:showTree change:allowRevRefs', @reRender
    @listenTo @state, 'change:chosen change:suggestions', @reRender
    @listenTo @openNodes, 'add remove reset', @reRender
    @listenTo @chosenPaths, 'add remove reset', @reRender
    @listenTo @chosenPaths, 'add remove reset', @setChosen
    @setChosen()
    @generatePathSuggestions()

  pathAcceptable: (path) ->
    if path.end?.name is 'id'
      return false
    if not @model.get 'canSelectReferences'
      return path.isAttribute()
    return true

  generatePathSuggestions: ->
    depth = Options.get 'SuggestionDepth'
    paths = (@query.makePath p for p in @query.getPossiblePaths depth)
    paths = paths.filter (p) => @pathAcceptable p
    namings = (p.getDisplayName() for p in paths)
    Promise.all namings
           .then (names) -> ({path, name} for [path, name] in _.zip paths, names)
           .then (suggestions) => @state.set {suggestions}

  getData: ->
    anyNodesOpen = @openNodes.size()
    anyNodeChosen = @chosenPaths.size()
    _.extend {anyNodesOpen, anyNodeChosen}, @state.toJSON(), super

  template: _.template options_html

  render: ->
    super
    if @state.has 'suggestions'
      @installTypeahead()
    this

  contains_i = (a, b) -> a.toLowerCase().indexOf(b) >= 0

  installTypeahead: ->
    @removeTypeAheads() # no more than one at a time.
    input = @$ '.im-tree-filter'
    suggestions = @state.get 'suggestions'
    suggest = (term, cb) ->
      parts = (term?.toLowerCase()?.split(' ') ? [])
      matches = ({path, name}) -> _.all parts, (p) ->
        console.log path
        contains_i(path.toString(), p) or contains_i(name, p)
      cb(s for s in suggestions when matches s)

    opts =
      minLength: 3
      highlight: true
    dataset =
      name: 'path_suggestions'
      source: suggest
      displayKey: 'name'
    @activateTypeahead input, opts, dataset, suggestions[0].name, (e, suggestion) =>
      path = suggestion.path
      @openNodes.add path
      if @model.get 'multiSelect'
        @chosenPaths.add path
      else
        @chosenPaths.reset [path]

  events: ->
    'click .im-collapser': 'collapseBranches'
    'change .im-allow-rev-ref': 'toggleReverseRefs'
    'change .im-tree-filter': 'setFilter'
    'click .im-choose': 'toggleShowTree'
    'click .im-approve': 'triggerApproval'
    'click .im-clear-filter': 'clearFilter'

  triggerApproval: -> @model.trigger 'approved'

  remove: ->
    @removeTypeAheads() # here rather in removeAllChildren, since it was causing errors.
    super

  clearFilter: ->
    @model.set filter: null
    @reRender()

  setFilter: (e) ->
    value = e.target.value
    @model.set filter: (if IS_BLANK.test(value) then null else value)

  collapseBranches: -> @openNodes.reset()

  toggleShowTree: -> @model.toggle 'showTree'

  toggleReverseRefs: -> @model.toggle 'allowRevRefs'

  setConstraint: -> @model.trigger 'approved'

  setChosen: ->
    paths = @chosenPaths.toJSON()
    naming = Promise.all(p.getDisplayName() for p in paths)
    naming.then ((names) => @state.set chosen: names), ((e) -> console.error e)


