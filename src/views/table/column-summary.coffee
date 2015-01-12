CoreView = require '../../core-view'
Options = require '../../options'

SummaryItems = require '../../models/summary-items'
ColumnSummary = require '../column-summary'
SummaryHeading = require '../facets/summary-heading'

SetsPathNames = require '../../mixins/sets-path-names'

{getColumnSummary} = require '../../services/column-summary'

module.exports = class DropDownColumnSummary extends CoreView

  @include SetsPathNames

  className: "im-dropdown-summary"

  initialize: ({@query}) ->
    super
    @items = new SummaryItems {fetch: _.partial getColumnSummary @query, @model.get 'path'}
    @getNames()
    @listenForChange @model, @getNames, 'path'

  getNames: -> # Do this here so that we have it available in all downstream components.
    @view = @model.get 'path'
    @setPathNames()

  getSummaryArgs: ->
    view: @model.get 'path'
    model: @state
    collection: @items
    noTitle: true

  # templateless render - this just a basic composition of two sub-views
  postRender: ->
    view = @model.get 'path'
    model = @state # The state becomes the model of the the children.
    # Create two child views, which share the same model representing the summary information.
    @renderChild 'heading', (new SummaryHeading {@query, view, model})
    @renderChild 'summary', ColumnSummary.create @getSummaryArgs()

