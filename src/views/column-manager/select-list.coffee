_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

SelectedColumn = require './selected-column'
UnselectedColumn = require './unselected-column'

childId = (model) -> "path_#{ model.get 'id' }"
binnedId = (model) -> "expath_#{ model.get 'id' }"

module.exports = class SelectListEditor extends CoreView

  parameters: ['query', 'collection', 'rubbishBin']

  className: 'im-select-list-editor'

  template: Templates.template 'column-manager-select-list'

  getData: -> _.extend super, hasRubbish: @rubbishBin.size()

  initialize: ->
    super
    @listenTo @rubbishBin, 'remove', @restoreView

  collectionEvents: ->
    'change:index': 'reSort'
    'remove': 'moveToBin'
    'add remove': 'reRender'

  events: ->
    'drop .im-rubbish-bin': 'onDragToBin'
    'sortupdate .im-active-view': 'onOrderChanged'

  onDragToBin: (e, ui) -> ui.draggable.trigger 'binned'

  moveToBin: (model) -> @rubbishBin.add @query.makePath model.get 'path'

  restoreView: (model) -> @collection.add @query.makePath model.get 'path'

  onOrderChanged: (e, ui) ->
    kids = @children
    views = @collection.map (model) -> kids[childId model]
    sorted = _.sortBy views, (v) -> v.$el.offset().top
    for v, i in sorted
      v.model.set index: i

  reSort: -> @collection.sort()

  postRender: ->
    columns = @$ '.im-active-view'
    binnedCols = @$ '.im-removed-view'

    @collection.each (model) =>
      @renderChild (childId model), (new SelectedColumn {model}), columns
    @rubbishBin.each (model) =>
      @renderChild (binnedId model), (new UnselectedColumn {model}), binnedCols

    columns.sortable
      placeholder: 'im-view-list-placeholder'
      opacity: 0.6
      cancel: 'i,a,button'
      axis: 'y'
      appendTo: @el

    @$('.im-rubbish-bin').droppable
      accept: '.im-selected-column'
      activeClass: 'im-can-remove-column'
      hoverClass: 'im-will-remove-column'

  remove: ->
    if @rendered
      @$('.im-active-view').sortable 'destroy'
      @$('.im-rubbish-bin').droppable 'destroy'
    super
    
