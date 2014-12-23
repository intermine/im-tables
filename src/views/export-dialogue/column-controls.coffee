_ = require 'underscore'
View = require '../../core-view'
PathSet = require '../../models/path-set'
LabelView = require '../label-view'
Messages = require '../../messages'
Templates = require '../../templates'
HasTypeaheads = require '../../mixins/has-typeaheads'
pathSuggester = require '../../utils/path-suggester'

class HeadingLabel extends LabelView

  template: _.partial Messages.getText, 'export.category.Columns'

class AddColumnControl extends View

  @include HasTypeaheads

  initialize: ({@columns, @query}) ->
    super
    @initSuggestions()

  addSuggestion: (path) ->
    unless @columns.contains path
      @suggestions.add(path)
      m = @suggestions.get path
      path.getDisplayName (error, name) -> m.set {error, name}

  initSuggestions: ->
    @suggestions = new PathSet
    nodes = @query.getQueryNodes()
    for node in nodes
      for cn in node.getChildNodes() when cn.isAttribute()
        @addSuggestion cn unless @columns.contains cn

  postRender: ->
    input = @$ 'input'
    opts =
      minLength: 1
      highlight: true
    dataset =
      name: 'view_suggestions'
      source: pathSuggester(@suggestions)
      displayKey: 'name'
    @activateTypeahead input, opts, dataset, 'Additional paths', (e, suggestion) =>
      path = suggestion.item
      @columns.add path, active: true

  className: 'col-sm-8'

  template: Templates.template 'export_add_column_control'

class ResetButton extends View

  className: 'col-sm-4'

  RERENDER_EVENT: 'change:isAll'

  initialize: ({@query, @columns}) ->
    super
    @model.set isAll: true
    @listenTo @columns, 'change:active', @setIsAll

  setIsAll: ->
    view = @query.views
    cols = (c.get('item').toString() for c in @columns.where active: true)
    @model.set isAll: _.isEqual(view, cols)


  # Template should be renamed, since it is not rows specific
  template: Templates.template 'export_rows_reset_button'

  events: ->
    'click button': 'reset'

  reset: ->
    view = @query.views
    @columns.each (c) ->
      path = c.get('item').toString()
      c.set active: _.any(view, (v) -> v is path)

class ColumnView extends View

  RERENDER_EVENT: 'change'

  initialize: ->
    super
    @model.set(active: true) unless @model.has 'active'
    unless @model.has('name')
      @model.set name: null # make sure it is present.
      @model.get('item').getDisplayName (error, name) =>
        @model.set {error, name}

  className: 'list-group-item'

  events: ->
    'click .im-active-state': => @model.toggle 'active'

  tagName: 'li'

  template: Templates.template 'export_column_control'

module.exports = class ColumnControls extends View

  className: 'container-fluid'

  initialize: ({@query}) ->
    super
    @columns = new PathSet
    # (re)-establish the state of the column selection, including
    # columns from the view that are not currently selected.
    activeCols = @model.get 'columns'
    for v in @query.views
      p = @query.makePath v
      @columns.add p, active: (_.any activeCols, (ac) -> ac is v)
    for c in activeCols
      @columns.add @query.makePath(c), active: true

    @listenTo @columns, 'add remove reset change:active', @setColumns
    @listenTo @columns, 'add remove reset', @reRender

  setColumns: ->
    columns = (c.get('item').toString() for c in @columns.where active: true)
    @model.set columns: columns

  tagName: 'form'

  template: Templates.template 'export_column_controls'

  postRender: ->
    ul = @$ 'ul'
    ctrls = @$ '.controls'
    @columns.each (c, i) =>
      @renderChild i, (new ColumnView model: c), ul
    @renderChild 'reset', (new ResetButton {@query, @columns}), ctrls
    @renderChild 'add', (new AddColumnControl {@query, @columns}), ctrls

