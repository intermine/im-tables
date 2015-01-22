_ = require 'underscore'
View = require '../../core-view'

Options = require '../../options'
Icons = require '../../icons'

###
# Type expectations:
#  - @chosenPaths :: UniqItems
#  - @model :: CoreModel {multiSelect}
#  - @trail :: [PathInfo]
#  - @query :: Query
#  - @path :: PathInfo
#
###

notBlank = (s) -> s? and /\w/.test s

stripLeadingSegments = (name) -> name?.replace(/^.*\s*>/, '')

highlightMatch = (match) -> "<strong>#{ match }</strong>"

module.exports = class Attribute extends View

  tagName: 'li'

  events: ->
    'click a': 'handleClick'

  initialize: ({@chosenPaths, @view, @query, @path, @trail}) ->
    super
    @depth = @trail.length + 1
    @state.set
      visible: true
      highlitName: null
      name: @path.toString()

    @listenTo @chosenPaths, 'add remove reset', @handleChoice
    @listenTo @state, 'change:visible', @onChangeVisible
    @listenTo @state, 'change:highlitName', @render
    @listenTo @state, 'change:displayName', @render

    @path.getDisplayName().then (displayName) =>
      @state.set {displayName, name: stripLeadingSegments(displayName)}

  onChangeVisible: -> @$el.toggle @state.get 'visible'

  getFilterPatterns: ->
    filterTerms = @model.get('filter')
    if notBlank filterTerms
      (new RegExp(t, 'i') for t in filterTerms.split(/\s+/) when t)
    else
      []

  handleClick: (e) ->
    e.stopPropagation()
    e.preventDefault()

    if (@model.get 'dontSelectView') and (@view?.contains @path)
      return

    if @chosenPaths.contains @path
      @chosenPaths.remove @path
    else
      @choose()

  choose: -> # Depending on the selection mode, either add this, or select just this.
    if @model.get 'multiSelect'
      @chosenPaths.add @path
    else
      @chosenPaths.reset [@path]

  handleChoice: ->
    @$el.toggleClass 'active', @chosenPaths.contains @path

  setHighlitName: (regexps) -> # Set now if available, or wait until it is.
    if @state.has 'name'
      @state.set highlitName: @getHighlitName(regexps)
    else
      @state.once 'change:name', =>
        @state.set highlitName: @getHighlitName(regexps)

  getHighlitName: (regexps) ->
    name = @state.get('name')
    pathName = @path.end?.name
    highlit = name

    for r in regexps
      highlit = highlit.replace r, highlightMatch

    if /strong/.test highlit
      highlit
    else
      highlightMatch highlit # Highlight it all.

  getDisabled: -> false

  getData: ->
    title = if Options.get('ShowId') then "#{ @path } (#{ @path.getType() })" else ''
    name = if @state.get('highlitName') then @state.get('highlitName') else @state.escape('name')
    icon = Icons.icon 'Attribute'
    {icon, title, name}

  template: _.template """
    <a href="#" title="<%- title %>">
      <%= icon %>
      <span>
        <%= name %>
      </span>
    </a>
  """

  render: ->
    super
    @$el.toggleClass 'disabled', @getDisabled()
    if Options.get('ShowId')
      @$('a').tooltip placement: 'bottom'
    @handleChoice()
    if @view?
      @$el.toggleClass 'in-view', @view.contains @path
    this
