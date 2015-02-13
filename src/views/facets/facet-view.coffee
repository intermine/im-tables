Event = require '../../event'
CoreView = require '../../core-view'
Options = require '../../options'

# methods we are composing in.
SetsPathNames = require '../../mixins/sets-path-names'

# The data-model object.
SummaryItems = require '../../models/summary-items'
NumericRange = require '../../models/numeric-range'

# The child views of this view.
SummaryHeading = require './summary-heading'
FacetItems = require './items'
SelectedCount = require './selected-count'
FacetVisualisation = require './visualisation'

module.exports = class FacetView extends CoreView

  @include SetsPathNames

  className: -> 'im-facet-view'

  modelEvents: ->
    'change:min change:max': @setLimits

  stateEvents: ->
    'change:open': @honourOpenness

  parameters: ['query', 'view']

  optionalParameters: ['noTitle']

  Model: => new SummaryItems {@query, @view}

  # May inherit state, defines a model based on @query and @view
  initialize: ->
    super
    @range = new NumericRange
    @setPathNames()
    @setLimits()

  initState: ->
    @state.set(open: Options.get 'Facets.Initally.Open') unless @state.has 'open'

  setLimits: -> if @model.get 'numeric'
    @range.setLimits @model.pick 'min', 'max'

  # Conditions that must be true by initialisation.

  invariants: ->
    hasQuery: "No query"
    hasAttrView: "The view is not an attribute: #{ @view }"
    modelIsSummaryItemsModel: "The model is not a summary items model: #{ @model }"

  modelIsSummaryItemsModel: -> @model instanceof SummaryItems

  hasQuery: -> @query?

  hasAttrView: -> @view?.isAttribute?()

  # Rendering logic. This is a composed view that has no template of its own.

  postRender: ->
    @renderTitle()
    @renderVisualisation()
    @renderSelectedCount()
    @renderItems()
    @honourOpenness()

  renderTitle: ->
    @renderChild 'title', (new SummaryHeading {@model, @state}) unless @noTitle

  renderVisualisation: ->
    @renderChild 'viz', (new FacetVisualisation {@model, @state, @range})

  renderSelectedCount: ->
    @renderChild 'count', (new SelectedCount {@model, @range})

  renderItems: ->
    @renderChild 'facet', (new FacetItems {@model, @state, @range})

  honourOpenness: ->
    isOpen = @state.get 'open'
    wasOpen = @state.previous 'open'
    facet = @$ 'dd.im-facet'

    if isOpen
      facet.slideDown()
      @trigger 'opened', @
    else
      facet.slideUp()
      @trigger 'closed', @

    if wasOpen? and (isOpen isnt wasOpen)
      @trigger 'toggled', @

  # Event definitions and their handlers.

  events: ->
    'click .im-summary-heading': 'toggle'

  toggle: -> @state.toggle 'open'

  close: -> @state.set open: false

  open: -> @state.set open: true

