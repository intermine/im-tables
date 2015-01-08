CoreView = require '../../core-view'
Options = require '../../options'

SummaryHeading = require './summary-heading'
ColumnSummary = require '../column-summary'
SummaryItems = require '../../models/summary-items'

{setColumnSummary} = require '../../services/column-summary'

module.exports = class DropDownColumnSummary extends CoreView

  className: "im-dropdown-summary"

  initialize: ({@query}) ->
    super
    @items = new SummaryItems
    @fetchSummary = (_.partial setColumnSummary @state, @items, @query, @model.get 'path')
    @fetchSummary Options.get 'INITIAL_SUMMARY_ROWS'
    @listenForChange @model, @getNames, 'path'
    @getNames()

  getNames: -> # Do this here so that we have it available in all downstream components.
    view = @model.get 'path'
    service = @query.service
    type = view.getParent().getType()
    attr = view.end
    type.getDisplayName (error, typeName) => @state.set {error, typeName}
    view.getDisplayName (error, pathName) => @state.set {error, pathName}
    service.get "model/#{ type.name }/#{ attr.name }"
           .then ({name}) -> name # cf. {display}
           .then ((attrName) => @state.set {attrName}), ((error) => @state.set {error})

  getSummaryArgs: ->
    view: @model.get 'path'
    model: @state
    collection: @items
    noTitle: true
    fetchSummary: @fetchSummary

  # templateless render - this just a basic composition of two sub-views
  postRender: ->
    view = @model.get 'path'
    model = @state # The state becomes the model of the the children.
    # Create two child views, which share the same model representing the summary information.
    @renderChild 'heading', (new SummaryHeading {@query, view, model})
    @renderChild 'summary', ColumnSummary.create @getSummaryArgs()

