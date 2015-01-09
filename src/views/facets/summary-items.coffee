_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

SummaryItemsControls = require './summary-items-controls'
FacetRow = require './row'

# Null safe event ignorer, and blocker.
IGNORE = (e) -> if e?
  e.preventDefault()
  e.stopPropagation()

module.exports = class SummaryItems extends CoreView

  tagName: 'form'

  className: 'form'

  initialize: ({@query, @view}) ->
    super
    @listenTo @collection, 'add', @addItem
    @listenTo @collection, 'reset', @reRender

  # Invariants

  invariants: ->
    viewIsAttribute: "No view, or view not Attribute: #{ @view }"
    hasCollection: "No collection"

  viewIsAttribute: -> @view?.isAttribute()

  hasCollection: -> @collection?

  # The template, and data used by templates

  template: Templates.template 'summary_items'
 
  getData: -> _.extend super,
    hasMore: @hasMore()
    colClasses: (_.result @, 'colClasses')
    colHeaders: (_.result @, 'colHeaders')

  hasMore: -> @model.get('got') < @model.get('uniqueValues')

  colClasses: ['im-item-selector', 'im-item-value', 'im-item-count']

  colHeaders: [' ', 'Item', 'Count']

  # Subviews and post-render actions.

  postRender: ->
    @tbody = @$ '.im-item-table tbody'
    @addControls()
    @addItems()

  addControls: ->
    args = {@query, @view, @model, @collection}
    @renderChildAt '.im-summary-controls', (new SummaryItemsControls args)

  addItems: -> if @rendered # Wait until rendered.
    @collection.each (item) => @addItem item

  addItem: (model) -> if @rendered # Wait until rendered.
    @renderChild "row_#{ model.get('id') }", (new FacetRow {model}), @tbody

  # Event definitions and their handlers
 
  events: ->
    'click .im-load-more': 'loadMoreItems'
    'click .im-clear-value-filter': 'clearValueFilter'
    'keyup .im-filter-values': _.throttle @filterItems, 750, leading: false
    'submit': IGNORE # not a real form - do not submit.
    'click': IGNORE # trap bubbled events.

  loadMoreItems: ->
    return if @model.get 'loading'
    @collection.increaseLimit 2

  clearValueFilter: ->
    $input = @$ '.im-filter-values'
    $input.val null
    @collection.setFilterTerm null

  filterItems: (e) => # Bound method because it is throttled in events.
    $input = @$ '.im-filter-values'
    val = $input.val()
    @collection.setFilterTerm $input.val()

