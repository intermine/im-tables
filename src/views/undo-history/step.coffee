_ = require 'underscore'
CoreView = require '../../core-view'
Collection = require '../../core/collection'
Templates = require '../../templates'
M = require '../../messages'
PathModel = require '../../models/path'
ConstraintModel = require '../../models/constraint'
OrderElementModel = require '../../models/order-element'
QueryProperty = require './query-property-section'

require '../../messages/undo'
require '../../messages/constraints'

# A class annotation that adds an 'added :: bool'
# attribute to a Model
withAdded = (Base) -> class WithAddedAndRemoved extends Base
  defaults: -> _.extend super, added: false, removed: false

class ObjConstructorPM extends PathModel

  constructor: ({path}) -> super path

class ViewList extends Collection

  model: withAdded ObjConstructorPM

class ConstraintList extends Collection

  model: withAdded ConstraintModel

class SortOrder extends Collection

  model: withAdded OrderElementModel

# Return a factory that will lift .path and .type to Path from strings.
liftPathAndType = (query) -> (obj) ->
  obj = if (_.isString obj) then {path: obj} else obj
  attrs = path: query.makePath obj.path
  attrs.type = query.makePath obj.type if obj.type 
  _.extend attrs, (_.omit obj, 'path', 'type')

module.exports = class UndoStep extends CoreView

  className: 'im-step'
  tagName: 'li'
  template: Templates.template 'undo-history-step'

  getData: -> _.extend super, diff: @getCountDiff()

  getCountDiff: ->
    if @state.has 'prevCount'
      @model.get('count') - @state.get('prevCount')
    else
      null

  initialize: ->
    super
    q = @model.get 'query'
    @initPrevCount()
    lifter = liftPathAndType q
    @listenTo @model.collection, 'add remove', @setCurrent
    @views = new ViewList q.views.map lifter
    @constraints = new ConstraintList q.constraints.map lifter
    @sortOrder = new SortOrder q.sortOrder.map lifter
    title = @model.get 'title'
    if title.verb in ['Added', 'Removed', 'Changed']
      switch title.label
        when 'column' then @diffView()
        when 'sort order element' then @diffSortOrder()
        when 'filter' then @diffConstraints()
        else console.log 'Cannot diff', title.label

  initPrevCount: -> if prev = @getPrevModel()
    @state.set prevCount: prev.get 'count'
    @listenTo prev, 'change:count', => @state.set prevCount: prev.get 'count'

  getPrevModel: ->
    index = @model.collection.indexOf @model
    return null if index is 0
    @model.collection.at index - 1

  diff: (prop, coll, test) ->
    prev = @getPrevModel()
    currQuery = @model.get 'query'
    prevQuery = prev.get 'query'
    # Find added, mark as such.
    for e, i in currQuery[prop] when test e, prevQuery
      coll.at(i).set added: true
    # Find removed elements, add them and mark them as such
    lifter = liftPathAndType prevQuery
    for e, i in prevQuery[prop] when test e, currQuery
      coll.add(lifter(e), at: i).set removed: true

  diffView: ->
    @diff 'views', @views, (v, {views}) -> v not in views

  diffSortOrder: ->
    @diff 'sortOrder', @sortOrder, (oe, q) ->
      not _.findWhere q.sortOrder, oe

  diffConstraints: ->
    @diff 'constraints', @constraints, (c, q) ->
      not _.findWhere q.constraints, c

  initState: ->
    @setCurrent()

  setCurrent: ->
    return unless @model?.collection # When removed the collection goes away.
    index = @model.collection.indexOf @model
    size = @model.collection.size()
    @state.set current: (index is size - 1)

  stateEvents: ->
    'change': @reRender

  modelEvents: -> # the only prop we expect to change is count.
    'change': @reRender

  events: ->
    'click .btn.im-state-revert': 'revertToState'
    click: (e) -> e.preventDefault(); e.stopPropagation()

  revertToState: ->
    @model.collection.revertTo @model

  postRender: ->
    @$details = @$ '.im-step-details'
    @$('.btn[title]').tooltip placement: 'right'
    # Only show what has changed.
    if @state.get('current')
      @renderAllSections()
    else # Only render the section that changed.
      title = @model.get 'title'
      switch title.label
        when 'column' then @renderViews()
        when 'filter' then @renderConstraints()
        when 'sort order element' then @renderSortOrder()
        else console.log 'Cannot render', title.label

  renderAllSections: ->
    @renderViews()
    @renderConstraints()
    @renderSortOrder()

  renderViews: ->
    @renderChild 'views', (new SelectListView collection: @views), @$details

  renderSortOrder: ->
    @renderChild 'so', (new SortOrderView collection: @sortOrder), @$details

  renderConstraints: ->
    @renderChild 'cons', (new ConstraintsView collection: @constraints), @$details

class SelectListView extends QueryProperty

  summaryLabel: 'undo.ViewCount'
  labelContent: (view) -> view.displayName

class SortOrderView extends QueryProperty

  summaryLabel: 'undo.OrderElemCount'
  labelContent: (oe) -> "#{ oe.displayName } #{ oe.direction }"

class ConstraintsView extends QueryProperty

  summaryLabel: 'undo.ConstraintCount'

  valuesLength: (con) -> M.getText('constraints.NoOfValues', n: con.values.length)

  idsLength: (con) -> M.getText('constraints.NoOfIds', n: con.ids.length)

  labelContent: (con) ->
    parts = switch con.CONSTRAINT_TYPE
      when 'MULTI_VALUE'
        [con.displayName, con.op, con.values.length, @valuesLength con]
      when 'TYPE'
        [con.displayName, M.getText('constraints.ISA'), con.typeName]
      when 'IDS'
        [con.displayName, con.op, @idsLength con]
      when 'LOOKUP'
        [con.displayName, con.op, con.value, M.getText('constraints.LookupIn'), con.extraValue]
      else # ATTR_VALUE, LIST, LOOP
        [con.displayName, con.op, con.value]

    parts.join ' '
    

