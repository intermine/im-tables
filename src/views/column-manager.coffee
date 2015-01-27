_ = require 'underscore'

Modal = require './modal'

Templates = require '../templates'
Messages = require '../messages'
Collection = require '../core/collection'
PathModel = require '../models/path'
ColumnManagerTabs = require './column-manager/tabs'
SelectListEditor = require './column-manager/select-list'
SortOrderEditor = require './column-manager/sort-order'
AvailableColumns = require '../models/available-columns'
OrderByModel = require '../models/order-element'

require '../messages/columns'

# Requires ::modelFactory
class IndexedCollection extends Collection

  comparator: 'index'

  constructor: ->
    super
    @listenTo @, 'change:index', -> _.defer => @sort()

  modelFactory: Collection::model # by default, make a model.

  model: (args) =>
    index = @size()
    model = new @modelFactory args
    model.set {index}
    return model

class SelectList extends IndexedCollection

  modelFactory: PathModel

class OrderByList extends IndexedCollection

  modelFactory: OrderByModel

module.exports = class ColumnManager extends Modal

  parameters: ['query']

  modalSize: -> 'lg'

  className: -> super + ' im-column-manager'

  title: -> Messages.getText 'columns.DialogueTitle'

  primaryAction: -> Messages.getText 'columns.ApplyChanges'

  dismissAction: -> Messages.getText 'Cancel'

  act: -> unless @state.get 'disabled'
    @query.select @getCurrentView() # select the current view.
    @query.orderBy @getCurrentSortOrder() # order by the new sort-order.
    @resolve 'changed'

  stateEvents: ->
    'change:currentTab': @renderTabContent
    'change:adding': @setDisabled

  initialize: ->
    super
    # Populate the select list and sort-order with the current state of the
    # query.
    @selectList = new SelectList
    @rubbishBin = new SelectList
    @sortOrder = new OrderByList
    @availableColumns = new AvailableColumns
    # Populate the view
    for v in @query.views
      @selectList.add @query.makePath v
    # Populate the sort-order
    for {path, direction} in @query.sortOrder
      @sortOrder.add {direction, path: @query.makePath(path)}
    # Find the relevant sort paths which are not in the sort order already.
    for path in @getRelevantPaths() when (not @sortOrder.get path.toString())
      @availableColumns.add path, sort: false
    @availableColumns.sort() # sort once, when they are all added.

    @listenTo @selectList, 'sort add remove', @setDisabled
    @listenTo @sortOrder, 'sort add remove', @setDisabled

  getRelevantPaths: ->
    # Relevant paths are all the attributes of all the inner-joined query nodes.
    _.chain @query.getQueryNodes()
     .filter (n) => not @query.isOuterJoined n
     .map (n) -> (cn for cn in n.getChildNodes() when cn.isAttribute() and (cn.end.name isnt 'id'))
     .flatten()
     .value()

  getCurrentView: -> @selectList.pluck 'path'

  getCurrentSortOrder: -> @sortOrder.map (m) -> m.asOrderElement()

  setDisabled: ->
    return @state.set disabled: true if @state.get('adding') # cannot confirm while adding.
    currentView = @getCurrentView().join ' '
    initialView = @query.views.join(' ')
    currentSO = @sortOrder.map( (m) -> m.toOrderString() ).join ' '
    initialSO = @query.getSorting()
    viewUnchanged = (currentView is initialView)
    soUnchanged = (currentSO is initialSO)
    # if no changes, then disable, since there are no changes to apply.
    @state.set disabled: (viewUnchanged and soUnchanged)

  initState: -> # open the dialogue with the default tab open, and main button disabled.
    @state.set
      disabledReason: 'columns.NoChangesToApply'
      disabled: true
      currentTab: ColumnManagerTabs.TABS[0]

  renderTabs: ->
    @renderChild 'tabs', (new ColumnManagerTabs {@state}), @$ '.modal-body'

  renderTabContent: -> if @rendered
    main = switch @state.get('currentTab')
      when 'view' then new SelectListEditor {@state, @query, @rubbishBin, collection: @selectList}
      when 'sortorder' then new SortOrderEditor {@query, @availableColumns, collection: @sortOrder}
      else throw new Error "Cannot render #{ @state.get 'currentTab' }"
    @renderChild 'main', main, @$ '.modal-body'

  postRender: ->
    super
    @renderTabs()
    @renderTabContent()

  remove: ->
    @selectList.close()
    @rubbishBin.close()
    @sortOrder.close()
    @availableColumns.close()
    super




