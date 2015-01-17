_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

Checkbox = require '../../core/checkbox'
RowSurrogate = require './row-surrogate'

require '../../messages/summary'

bool = (x) -> !!x

# Row in the drop down summary.
module.exports = class FacetRow extends CoreView

  # Not all of these are expected to actually change,
  # but these are the things the template depends on.
  RERENDER_EVENT: 'change:count change:item change:symbol change:share'

  tagName: "tr"

  className: "im-facet-row"

  modelEvents: ->
    "change:visible": @onChangeVisibility
    "change:hover": @onChangeHover
    "change:selected": @onChangeSelected

  # Invariants

  invariants: -> modelHasCollection: "No collection on model"

  modelHasCollection: -> @model?.collection?
  
  # The template, and data used by templates
 
  template: Templates.template 'facet_row'

  getData: ->
    max = @model.collection.getMaxCount()
    ratio = @model.get('count') / max
    opacity = (ratio / 2 + 0.5).toFixed() # opacity ranges from 0.5 - 1
    percent = (ratio * 100).toFixed() # percentage is int from 0 - 100

    _.extend super, {percent, opacity, max}

  onRenderError: (e) -> console.error e

  # Subviews and interactions with the DOM.

  postRender: ->
    @addCheckbox()
    @onChangeVisibility()
    @onChangeHover()
    @onChangeSelected()

  addCheckbox: ->
    @renderChildAt '.checkbox', (new Checkbox {@model, attr: 'selected'})

  onChangeVisibility: -> @$el.toggleClass 'im-hidden', not @model.get "visible"

  onChangeHover: -> # can be hovered in the graph.
    isHovered = bool @model.get 'hover'
    @$el.toggleClass 'hover', isHovered
    if isHovered
      return @showSurrogateUnlessVisible()
    else
      return @removeSuggogate()

  onChangeSelected: -> @$el.toggleClass 'im-selected', @model.get('selected')

  removeSuggogate: ->
    @removeChild 'surrogate'

  showSurrogateUnlessVisible: ->
    @removeSuggogate() # to be sure
    unless @isVisible() # TODO - add styles for the surrogate
      above = @isAbove()
      surrogate = new RowSurrogate {@model, above}
      table = @getTable()
      @renderChild 'surrogate', surrogate, table
      newTop = if above
        table.offset().top + table.scrollTop()
      else
        table.scrollTop() + table.offset().top + table.outerHeight() - surrogate.outerHeight()
      surrogate.offset top: newTop

  getTable: -> @$el.closest('.im-item-table')

  # Events definitions and their handlers.

  events: -> 'click': 'handleClick'

  handleClick: (e) ->
    e.stopPropagation()
    @model.toggle 'selected'

  isBelow: () ->
    parent = @getTable()
    @$el.offset().top + @$el.outerHeight() > parent.offset().top + parent.outerHeight()

  isAbove: () ->
    parent = @getTable()
    @$el.offset().top < parent.offset().top

  isVisible: () -> not (@isAbove() or @isBelow())
