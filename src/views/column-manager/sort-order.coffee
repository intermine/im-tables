_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
AvailableColumns = require '../../models/available-columns'

AvailablePath = require './available-path'
OrderElement = require './order-element'

activeId = (model) -> "active_#{ model.get 'id' }"
inactiveId = (model) -> "inactive_#{ model.get 'id' }"

module.exports = class SortOrderEditor extends CoreView

  parameters: ['collection', 'query']

  className: 'im-sort-order-editor'

  template: Templates.template 'column-manager-sort-order-editor'

  getData: -> _.extend super, available: @availableColumns.size()

  collectionEvents: ->
    'add remove': @reRender

  initialize: ->
    super
    @availableColumns = new AvailableColumns
    # Find the relevant sort paths which are not in the sort order already.
    for path in @getRelevantPaths() when (not @collection.get path.toString())
      # sort once, when they are all added.
      @availableColumns.add path, sort: false
    @availableColumns.sort()
    @listenTo @availableColumns, 'sort', @resortAvailable
    @listenTo @availableColumns, 'remove', @addToSortOrder

  getRelevantPaths: ->
    # Relevant paths are all the attributes of all the inner-joined query nodes.
    _.chain @query.getQueryNodes()
     .filter (n) => not @query.isOuterJoined n
     .map (n) -> (cn for cn in n.getChildNodes() when cn.isAttribute() and (cn.end.name isnt 'id'))
     .flatten()
     .value()

  postRender: ->
    @resortSortOrder()
    @resortAvailable()
    @activateSortables()
    @setAvailableHeight()

  activateSortables: ->
    active = @$('.im-active-oes')

    if @collection.size()
      active.sortable
        placeholder: 'im-view-list-placeholder'
        opacity: 0.6
        cancel: 'i,a,button'
        axis: 'y'
        appendTo: @el
    else
      @$('.im-empty-collection').droppable
        accept: '.im-selected-column'
        activeClass: 'im-can-add-column'
        hoverClass: 'im-will-add-column'

  events: ->
    'drop .im-empty-collection': 'addSortElement'

  addSortElement: (e, ui) ->
    $el = ui.draggable
    kids = @children
    available = @availableColumns.find (m) ->
      kids[inactiveId m].el is $el[0]
    console.log 'lets add', available
    @addToSortOrder available

  addToSortOrder: (availableColumnModel) ->
    oe = path: (@query.makePath availableColumnModel.get 'path')
    availableColumnModel.destroy() # remove from collection, etc.
    @collection.add oe

  # Cleanest way I could think of to do this.
  resortAvailable: -> if @rendered
    frag = global.document.createDocumentFragment()
    @availableColumns.each (model) =>
      @renderChild (inactiveId model), (new AvailablePath {model}), frag
    @$('.im-available-oes').html frag

  resortSortOrder: -> if @rendered
    frag = global.document.createDocumentFragment()
    @collection.each (model) =>
      @renderChild (activeId model), (new OrderElement {model}), frag
    @$('.im-active-oes').html frag

  setAvailableHeight: ->
    @$('.im-rubbish-bin').css 'max-height': Math.max(200, (@$el.closest('.modal').height() - 450))

