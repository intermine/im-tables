_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

SelectedColumn = require './selected-column'

childId = (model) -> "path_#{ model.get 'id' }"

module.exports = class SelectListEditor extends CoreView

  parameters: ['query', 'collection']

  className: 'im-select-list-editor'

  template: Templates.template 'column-manager-select-list'

  collectionEvents: ->
    'add remove': 'reRender'

  events: ->
    'drop .im-rubbish-bin': 'onDragToBin'
    'sortupdate .im-current-view .list-group': 'onOrderChanged'

  onDragToBin: (e, ui) -> ui.draggable.trigger 'binned'

  onOrderChanged: (e, ui) ->
    kids = @children
    views = @collection.map (model) -> kids[childId model]
    sorted = _.sortBy views, (v) -> v.$el.offset().top
    for v, i in sorted
      v.model.set index: i
    @collection.sort()

  postRender: ->
    columns = @$ '.im-current-view .list-group'
    @collection.each (model) =>
      @renderChild (childId model), (new SelectedColumn {model}), columns

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
      @$('.im-current-view .list-group').sortable 'destroy'
      @$('.im-rubbish-bin').droppable 'destroy'
    super
    
