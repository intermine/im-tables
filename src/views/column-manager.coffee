_ = require 'underscore'

Modal = require './modal'

Templates = require '../templates'
Messages = require '../messages'
Collection = require '../core/collection'
PathModel = require '../models/path'
ColumnManagerTabs = require './column-manager/tabs'
SelectListEditor = require './column-manager/select-list'
SortOrderEditor = require './column-manager/sort-order'

require '../messages/columns'

class OrderByModel extends PathModel

  constructor: ({path, direction}) ->
    super path
    direction ?= 'ASC'
    @set {direction}

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

  className: -> super + ' im-column-manager'

  title: -> Messages.getText 'columns.DialogueTitle'

  primaryAction: -> Messages.getText 'columns.ApplyChanges'

  dismissAction: -> Messages.getText 'Cancel'

  act: -> unless @state.get 'disabled'
    @query.select @getCurrentView() # select the current view.
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
    for v in @query.views
      @selectList.add @query.makePath v
    @sortOrder = new OrderByList
    for {path, direction} in @query.sortOrder
      @sortOrder.add {direction, path: @query.makePath(path)}
    @listenTo @selectList, 'sort add remove', @setDisabled

  getCurrentView: -> @selectList.pluck 'path'

  setDisabled: ->
    return @state.set disabled: true if @state.get('adding') # cannot confirm while adding.
    currentView = @getCurrentView().join ' '
    initialView = @query.views.join(' ')
    @state.set disabled: (currentView is initialView) # no changes - nothing to do.

  initState: -> # open the dialogue with the default tab open, and main button disabled.
    @state.set disabled: true, currentTab: ColumnManagerTabs.TABS[0]

  renderTabs: ->
    @renderChild 'tabs', (new ColumnManagerTabs {@state}), @$ '.modal-body'

  renderTabContent: -> if @rendered
    main = switch @state.get('currentTab')
      when 'view' then new SelectListEditor {@state, @query, @rubbishBin, collection: @selectList}
      when 'sortorder' then new SortOrderEditor {@query, collection: @sortOrder}
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
    super




