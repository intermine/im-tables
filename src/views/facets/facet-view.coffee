Event = require '../../event'
CoreView = require '../../core-view'
Options = require '../../options'
Templates = require '../../templates'
SetsPathNames = require '../../mixins/sets-path-names'
SummaryItems = require '../../models/summary-items'
SummaryHeading = require './summary-heading'
{getColumnSummary} = require '../../services/column-summary'

class FacetTitle extends CoreView

  tagName: 'dt'

  initialize: ->
    super
    @listenForChange @model, @reRender, 'got'
    @listenForChange @state, @reRender, 'open', 'pathName'
  
  template: Templates.template 'facet_title'

module.exports = class FacetView extends CoreView

  @include SetsPathNames

  tagName: "dl"

  initialize: ({@query, @view, @noTitle}) ->
    super model: (new SummaryItems {fetch: _.partial getColumnSummary @query, @view})
    @state.set(open: Options.get 'Facets.Initally.Open') unless @state.has 'open'
    @listenTo @query, 'change:constraints', @reRender
    @listenTo @state, 'change:open', @honourOpenness
    @setPathNames()

  invariants: ->
    hasQuery: "No query"
    hasAttrView: "The view is not an attribute: #{ @view }"

  events: ->
    'click dt': 'toggle'

  toggle: -> @state.toggle 'open'

  close: -> @state.set open: false

  open: -> @state.set open: true

  honourOpenness: ->
    isOpen = @state.get 'open'
    facet = @$ 'dd.im-facet'
    evt = new Event @, @el
    @trigger 'toggle', evt
    return if evt.cancelled
    if isOpen
      facet.slideDown()
      @trigger 'opened', @
    else
      facet.slideUp()
      @trigger 'closed', @
    @trigger 'toggled', @

  renderTitle: ->
    @renderChild 'title', (new SummaryHeading {@model, @state}) unless @noTitle

  renderFacet: ->

  # TODO - move the rendering logic from table/column-summary here!
  postRender: ->
    @renderTitle()
    @renderChart()
    @renderFacet()
    @honourOpenness()

