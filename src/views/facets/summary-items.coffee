_ = require 'underscore'
Backbone = require 'backbone'

CoreView = require '../../core-view'
Templates = require '../../templates'
Messages = require '../../messages'
SetsPathNames = require '../../mixins/sets-path-names'

SummaryItemsControls = require './summary-items-controls'
FacetRow = require './row'

require '../../messages/summary'

# Null safe event ignorer, and blocker.
IGNORE = (e) -> if e?
  e.preventDefault()
  e.stopPropagation()

rowId = (model) -> "row_#{ model.get('id') }"

module.exports = class SummaryItems extends CoreView

  @include SetsPathNames

  tagName: 'div'

  className: 'im-summary-items'

  stateEvents: -> 'change:error': @setErrOnModel

  setErrOnModel: -> @model.set @state.pick 'error'

  initialize: ->
    super
    @listenTo @model.items, 'add', @addItem
    @listenTo @model.items, 'remove', @removeItem
    @listenTo @state, 'change:typeName change:endName', @reRender
    @setPathNames()

  # Things we need before we can start.
  invariants: ->
    modelHasItems: "expected a SummaryItems model, got: #{ @model }"
    modelCanHasMore: "expected the correct model methods, got: #{ @model }"

  modelHasItems: -> @model?.items instanceof Backbone.Collection

  modelCanHasMore: -> _.isFunction @model?.hasMore

  # The template, and data used by templates

  template: Templates.template 'summary_items'
 
  getData: -> _.extend super,
    hasMore: @model.hasMore()
    colClasses: (_.result @, 'colClasses')
    colHeaders: (_.result @, 'colHeaders')

  colClasses: ['im-item-selector', 'im-item-value', 'im-item-count']

  colHeaders: ->
    itemColHeader = if @state.has 'typeName'
      "#{ @state.get 'typeName' } #{ @state.get 'endName' }"
    else
      Messages.getText 'summary.Item'

    [' ', itemColHeader, (Messages.getText 'summary.Count')]

  # Subviews and post-render actions.

  postRender: ->
    @tbody = @$ '.im-item-table tbody'
    throw new Error 'Could not find table' unless @tbody.length
    @addControls()
    @addItems()

  addControls: ->
    @renderChildAt '.im-summary-controls', (new SummaryItemsControls {@model})

  addItems: -> if @rendered # Wait until rendered.
    @model.items.each (item) => @addItem item

  addItem: (model) -> if @rendered # Wait until rendered.
    @renderChild (rowId model), (new FacetRow {model}), @tbody

  removeItem: (model) -> @removeChild rowId model

  # Event definitions and their handlers
 
  events: ->
    'click .im-load-more': 'loadMoreItems'
    'click .im-clear-value-filter': 'clearValueFilter'
    'keyup .im-filter-values': (_.throttle @filterItems, 250, leading: false)
    'submit': IGNORE # not a real form - do not submit.
    'click': IGNORE # trap bubbled events.

  loadMoreItems: ->
    return if @model.get 'loading'
    @model.increaseLimit 2

  clearValueFilter: ->
    $input = @$ '.im-filter-values'
    $input.val null
    @model.setFilterTerm null

  filterItems: (e) => # Bound method because it is throttled in events.
    $input = @$ '.im-filter-values'
    val = $input.val()
    @model.setFilterTerm $input.val()

