_ = require 'underscore'
View = require '../../core-view'
PathSet = require '../../models/path-set'
LabelView = require '../label-view'
Messages = require '../../messages'
Templates = require '../../templates'

class HeadingLabel extends LabelView

  template: _.partial Messages.getText, 'export.category.Columns'

class ResetButton extends View

  RERENDER_EVENT: 'change'

  template: Templates.template 'export_rows_reset_button'

  events: ->
    'click button': 'reset'

  reset: ->
    @model.set start: 0, size: null

class ColumnView extends View

  RERENDER_EVENT: 'change'

  initialize: ->
    super
    @model.set(active: true) unless @model.has 'active'
    unless @model.has('name')
      @model.set name: null # make sure it is present.
      @model.get('item').getDisplayName (error, name) =>
        console.log error, name
        @model.set {error, name}

  className: 'list-group-item'

  events: ->
    'click .im-active-state': => @model.toggle 'active'

  tagName: 'li'

  template: Templates.template 'export_column_control'

module.exports = class ColumnControls extends View

  initialize: ({@query}) ->
    super
    @columns = new PathSet
    # (re)-establish the state of the column selection, including
    # columns from the view that are not currently selected.
    activeCols = @model.get 'columns'
    for v in @query.views
      p = @query.makePath v
      @columns.add p, active: (_.any activeCols, (ac) -> ac is v)

    @listenTo @columns, 'add remove reset change:active', @setColumns

  setColumns: ->
    columns = (c.get('item').toString() for c in @columns.where active: true)
    @model.set columns: columns

  tagName: 'form'

  template: Templates.template 'export_column_controls'

  postRender: ->
    ul = @$ 'ul'
    @columns.each (c, i) => @renderChild i, (new ColumnView model: c), ul

