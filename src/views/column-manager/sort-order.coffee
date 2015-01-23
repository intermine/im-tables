_ = require 'underscore'

CoreView = require '../../core-view'
CoreModel = require '../../core-model'
Templates = require '../../templates'
AvailableColumns = require '../../models/available-columns'
HandlesDOMReSort = require '../../mixins/handles-dom-resort'

AvailablePath = require './available-path'
OrderElement = require './order-element'

activeId = (model) -> "active_#{ model.get 'id' }"
inactiveId = (model) -> "inactive_#{ model.get 'id' }"

module.exports = class SortOrderEditor extends CoreView

  @include HandlesDOMReSort

  parameters: ['collection', 'query']

  className: 'im-sort-order-editor'

  template: Templates.template 'column-manager-sort-order-editor'

  getData: -> _.extend super, available: @availableColumns.size()

  collectionEvents: ->
    'add remove': @reRender
    'sort': @resortSortOrder
    'remove': @makeAvailable

  initialize: ->
    super
    @dragState = new CoreModel
    @availableColumns = new AvailableColumns
    # Find the relevant sort paths which are not in the sort order already.
    for path in @getRelevantPaths() when (not @collection.get path.toString())
      # sort once, when they are all added.
      @availableColumns.add path, sort: false
    @availableColumns.sort()
    @listenTo @availableColumns, 'sort add remove', @resortAvailable
    @listenTo @availableColumns, 'remove', @addToSortOrder

  getRelevantPaths: ->
    # Relevant paths are all the attributes of all the inner-joined query nodes.
    _.chain @query.getQueryNodes()
     .filter (n) => not @query.isOuterJoined n
     .map (n) -> (cn for cn in n.getChildNodes() when cn.isAttribute() and (cn.end.name isnt 'id'))
     .flatten()
     .value()

  currentSortOrder: ->
    @collection.map (m) -> "#{ m.get 'path' } #{ m.get 'direction' }"
               .join ' '

  postRender: ->
    console.log @currentSortOrder()
    # First we render the sort-order.
    @resortSortOrder()
    # Then we activate the drag/drop/sort-ables - this must be done
    # before we render the available paths, since they need a reference
    # to the active paths, which is created in ::activateSortables
    @activateSortables()
    # render the available paths.
    @resortAvailable()
    @setAvailableHeight()

  activateSortables: ->
    active = @$('.im-active-oes')

    if @collection.size()
      @$actives = active.sortable
        placeholder: 'im-view-list-placeholder'
        opacity: 0.6
        cancel: 'i,a,button'
        axis: 'y'
        appendTo: @el
    else
      @$droppable = @$('.im-empty-collection').droppable
        accept: '.im-selected-column'
        activeClass: 'im-can-add-column'
        hoverClass: 'im-will-add-column'

  removeAllChildren: ->
    @$actives?.sortable 'destroy'
    @$droppable?.droppable 'destroy'
    @$droppable = null
    @$actives = null
    super

  events: ->
    'drop .im-empty-collection': 'addSortElement'
    'sortupdate .im-active-oes': 'onDOMResort'

  onDOMResort: (e, ui) ->
    if path = @dragState.get 'dragged'
      model = @availableColumns.findWhere {path}
      indexAt = ui.item.prevAll().length
      @addToSortOrder model, indexAt
      @dragState.unset 'dragged'
    else
      @setChildIndices activeId

  makeAvailable: (active) ->
    @availableColumns.add @query.makePath active.get 'path'

  findAvailable: (el) -> @availableColumns.find (m) =>
    @children[inactiveId m]?.el is el

  addSortElement: (e, ui) ->
    $el = ui.draggable
    available = @findAvailable $el[0]
    console.log 'lets add', available
    @addToSortOrder available

  addToSortOrder: (availableColumnModel, atIndex) ->
    path = @query.makePath availableColumnModel.get 'path'
    oe = id: (String path), path: path
    sizeBeforeAdd = @collection.size()
    # remove from collection, etc.
    availableColumnModel.destroy()
    @collection.add oe
    if atIndex? and (atIndex < sizeBeforeAdd)
      toBump = @collection.filter (m) -> m.get('index') >= atIndex
      added = @collection.last()
      for b in toBump
        b.swap 'index', (idx) -> idx + 1
      added.set index: atIndex

  # Cleanest way I could think of to do this.
  resortAvailable: -> if @rendered
    frag = global.document.createDocumentFragment()
    @availableColumns.each (model) =>
      @_renderAvailable model, frag
    @$('.im-available-oes').html frag

  _renderAvailable: (model, frag) ->
    name = inactiveId model
    findActives = => @$actives
    view = new AvailablePath {model, findActives, state: @dragState}
    @renderChild name, view, frag

  resortSortOrder: -> if @rendered
    frag = global.document.createDocumentFragment()
    @collection.each (model) =>
      @renderChild (activeId model), (new OrderElement {model}), frag
    @$('.im-active-oes').html frag

  setAvailableHeight: ->
    @$('.im-rubbish-bin').css 'max-height': Math.max(200, (@$el.closest('.modal').height() - 450))

  remove: ->
    @availableColumns.close()
    @dragState.destroy()
    super
