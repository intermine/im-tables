_ = require 'underscore'
CoreView = require '../../core-view'
Collection = require '../../core/collection'
Templates = require '../../templates'
PathModel = require '../../models/path'
ConstraintModel = require '../../models/constraint'
OrderElementModel = require '../../models/order-element'
QueryProperty = require './query-property-section'

{count} = require '../../utils/count-executor'

require '../../messages/undo'

# A class annotation that adds an 'added :: bool'
# attribute to a Model
withAdded = (Base) -> class WithAdded extends Base
  defaults: -> _.extend super, added: false

class ViewList extends Collection

  model: withAdded PathModel

class ConstraintList extends Collection

  model: withAdded ConstraintModel

class SortOrder extends Collection

  model: withAdded OrderElementModel

# Return a factory that will lift .path and .type to Path from strings.
liftPathAndType = (query) -> (con) ->
  attrs = path: query.makePath con.path
  attrs.type = query.makePath con.type if con.type 
  _.extend attrs, (_.omit con, 'path', 'type')

module.exports = class UndoStep extends CoreView

  className: 'im-step'
  tagName: 'li'
  template: Templates.template 'undo-history-step'

  initialize: ->
    super
    q = @model.get 'query'
    count(q).then (c) => @state.set count: c
    lifter = liftPathAndType q
    @listenTo @model.collection, 'add remove', @setCurrent
    @views = new ViewList( q.makePath v for v in q.views )
    @constraints = new ConstraintList q.constraints.map lifter
    @sortOrder = new SortOrder q.sortOrder.map lifter
    title = @model.get 'title'
    console.log title
    if title.verb is 'Added'
      switch title.label
        when 'column' then @diffView()
        when 'sort order element' then @diffSortOrder()
        when 'filter' then @diffConstraints()
        else console.log 'Cannot diff', title.label

  diff: (prop, coll, test) ->
    index = @model.collection.indexOf @model
    prev = @model.collection.at index - 1
    currQuery = @model.get 'query'
    prevQuery = prev.get 'query'
    for e, i in currQuery[prop] when test e, prevQuery
      coll.at(i).set added: true

  diffView: ->
    @diff 'views', @views, (v, {views}) -> v not in views

  diffSortOrder: ->
    @diff 'sortOrder', @sortOrder, (oe, q) ->
      not _.findWhere q.sortOrder, oe

  diffConstraints: ->
    @diff 'constraints', @constraints, (c, q) ->
      not _.findWhere q.constraints, c

  initState: ->
    @state.set count: 0
    @setCurrent()

  setCurrent: ->
    index = @model.collection.indexOf @model
    size = @model.collection.size()
    @state.set current: (index is size - 1)

  stateEvents: ->
    'change': @reRender

  postRender: ->
    @$details = @$ '.im-step-details'
    @$('.btn[title]').tooltip placement: 'right'
    @renderViews()
    @renderSortOrder()

  renderViews: ->
    @renderChild 'views', (new SelectListView collection: @views), @$details

  renderSortOrder: ->
    @renderChild 'so', (new SortOrderView collection: @sortOrder), @$details

class SelectListView extends QueryProperty

  summaryLabel: 'undo.ViewCount'
  labelContent: (view) -> view.displayName

class SortOrderView extends QueryProperty

  summaryLabel: 'undo.OrderElemCount'
  labelContent: (oe) -> "#{ oe.displayName } #{ oe.direction }"

