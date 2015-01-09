CoreView = require '../../core-view'
Templates = require '../../templates'

RowSurrogate = require './row-surrogate'

# Row in the drop down summary.
module.export = class FacetRow extends CoreView

  # Not all of these are expected to actually change, but these are the things
  # the template depends on.
  RERENDER_EVT: 'change:count change:selected change:item change:symbol change:share'

  tagName: "tr"

  className: "im-facet-row"

  initialize: ->
    super
    @listenTo @model, "change:visible", @onChangeVisibility
    @listenTo @model, "change:hover", @onChangeHover

  # Invariants

  invariants: -> modelHasCollection: "No collection on model"

  modelHasCollection: -> @model?.collection?
  
  # The template, and data used by templates
 
  template: Templates.template 'facet_row'

  getData: ->
    ratio = (parseInt @model.get('count'), 10) / @model.collection.getMaxCount()
    opacity = (ratio / 2 + 0.5).toFixed() # opacity ranges from 0.5 - 1
    percent = (ratio * 100).toFixed() # percentage is int from 0 - 100

    _.extend super, {percent, opacity}

  # Subviews and interactions with the DOM.

  postRender: ->
    @onChangeVisibility()
    @onChangeHover()

  onChangeVisibility: -> @$el.toggleClass 'im-hidden', @model.get "visible"

  onChangeHover: -> # can be hovered in the graph.
    isHovered = @model.get 'hover'
    @$el.toggleClass 'hover', isHovered
    if isHovered
      return @showSurrogateUnlessVisible()
    else
      return @removeSuggogate()

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
