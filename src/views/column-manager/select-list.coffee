_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'
Collection = require '../../core/collection'

HandlesDOMReSort = require '../../mixins/handles-dom-resort'

SelectedColumn = require './selected-column'
UnselectedColumn = require './unselected-column'
ColumnChooser = require './path-chooser'

childId = (model) -> "path_#{ model.get 'id' }"
binnedId = (model) -> "expath_#{ model.get 'id' }"
incr = (x) -> x + 1

module.exports = class SelectListEditor extends CoreView

  @include HandlesDOMReSort

  parameters: ['query', 'collection', 'rubbishBin']

  className: 'im-select-list-editor'

  template: Templates.template 'column-manager-select-list'

  getData: -> _.extend super, hasRubbish: @rubbishBin.size()

  initialize: ->
    super
    @listenTo @rubbishBin, 'remove', @restoreView

  initState: ->
    @state.set adding: false

  collectionEvents: ->
    'remove': 'moveToBin'
    'add remove': 'reRender'

  events: ->
    'drop .im-rubbish-bin': 'onDragToBin'
    'sortupdate .im-active-view': 'onOrderChanged'
    'click .im-add-view-path': 'setAddingTrue'

  stateEvents: ->
    'change:adding': 'onChangeMode'

  setAddingTrue: -> @state.set adding: true

  onDragToBin: (e, ui) -> ui.draggable.trigger 'binned'

  moveToBin: (model) ->
    @rubbishBin.add @query.makePath model.get 'path'
    @reIndexFrom model.get 'index'

  reIndexFrom: (idx) ->
    for i in [idx .. @collection.size()]
      @collection.at(i)?.set index: i

  restoreView: (model) -> @collection.add @query.makePath model.get 'path'

  onChangeMode: -> if @rendered
    if @state.get 'adding'
      @$('.im-removal-and-rearrangement').hide()
      @$('.im-addition').show()
      @renderPathChooser()
    else
      @$('.im-removal-and-rearrangement').show()
      @$('.im-addition').hide()
      @removeChild 'columnChooser'

  renderPathChooser: ->
    columns = new ColumnChooser {@query, @collection}
    @listenTo columns, 'done', => @state.set adding: false
    @renderChild 'columnChooser', columns, @$ '.im-addition'

  onOrderChanged: (e, ui) ->
    if ui.sender?
      @restoreFromBin ui.item
    else
      @onDOMResort()

  getInsertPoint: ($el) ->
    addedAfter = $el.prev()
    kids = @children

    prevModel = @collection.find (m) ->
      active = kids[childId m]
      active.el is addedAfter[0]

    if not prevModel?
      return 0 # Nothing in front, we are first, yay.
    else # We are added at the index after the one in front.
      return prevModel.get('index') + 1

  getRestoredModel: ($el) -> @rubbishBin.find (m) =>
    binned = @children[binnedId m]
    binned?.el is $el[0]

  # jQuery UI sortable does not give us indexes - so we have
  # to work those out ourselves, very annoyingly.
  restoreFromBin: ($el) ->
    kids = @children                  #:: {string -> View}
    preAddSize = @collection.size()   #:: int
    addedAt = @getInsertPoint $el     #:: int
    toRestore = @getRestoredModel $el #:: Model?

    # Destroy the binned view - this triggers the model's
    # removal from the bin, which triggers restoreView - so
    # once it returns, the path has been added back to the view.
    if toRestore?
      toRestore.destroy()
    else
      console.error 'could not find model for:', $el
      return # Something went wrong, nothing we can do.
    # Added at end - our work is done.
    return if addedAt is preAddSize

    # At this point, the path has been restored - but
    # we still need to put it in the correct place.
    # first find the models we need to bump to the right.
    toBump = (@collection.at i for i in [addedAt ... preAddSize])
    # The one we added is always the last.
    added = @collection.last()
    # Bump the ones after us to the right.
    for m in toBump
      m.swap 'index', incr
    # Set the index of the newly added model.
    added.set index: addedAt
    # OK, so the state is correct, we just have to put the new
    # element in the right place, which is done with this horror:
    # While this is slightly ugly, it is much more efficient
    # than the alternative, which is to reposition on the sort
    # event, since this is O(1), not O(n*n).
    kids[childId added].$el.insertBefore kids[childId toBump[0]].el

  onDOMResort: -> @setChildIndices childId

  postRender: ->
    columns = @$ '.im-active-view'
    binnedCols = @$ '.im-removed-view'

    #TODO: cut-and paste from sort-order.coffee - move to separate file.
    cutoff = 900
    modalWidth = @$el.closest('.modal').width()
    wide = (modalWidth >= cutoff)

    @collection.each (model) =>
      @renderChild (childId model), (new SelectedColumn {model}), columns
    @rubbishBin.each (model) =>
      @renderChild (binnedId model), (new UnselectedColumn {model}), binnedCols

    columns.sortable
      placeholder: 'im-view-list-placeholder'
      opacity: 0.6
      cancel: 'i,a,button'
      axis: (if wide then null else 'y')
      appendTo: @el

    @$('.im-removed-view').sortable
      placeholder: 'im-view-list-placeholder'
      connectWith: columns
      opacity: 0.6
      cancel: 'i,a,button'
      axis: (if wide then null else 'y')
      appendTo: @el

    @$('.im-rubbish-bin').droppable
      accept: '.im-selected-column'
      activeClass: 'im-can-remove-column'
      hoverClass: 'im-will-remove-column'

    @onChangeMode() # make sure we are in the right mode.

  removeAllChildren: ->
    if @rendered
      @$('.im-active-view').sortable 'destroy'
      @$('.im-removed-view').sortable 'destroy'
      @$('.im-rubbish-bin').droppable 'destroy'
    super
