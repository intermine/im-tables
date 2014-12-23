_ = require 'underscore'

Model = require '../core-model'
Modal = require './modal'
ConstraintAdder = require './constraint-adder'
Messages = require '../messages'
Templates = require '../templates'

Menu = require './export-dialogue/tab-menu'
FormatControls = require './export-dialogue/format-controls'
RowControls = require './export-dialogue/row-controls'
ColumnControls = require './export-dialogue/column-controls'

class ExportModel extends Model

  defaults: ->
    format: 'tsv'
    start: 0
    columns: []
    size: null
    max: null

isa = (target) -> (path) -> path.isa target

# A complex dialogue that delegates the configuration of different
# export parameters to subviews.
module.exports = class ExportDialogue extends Modal

  Model: ExportModel

  className: -> 'im-export-dialogue ' + super

  initialize: ({@query}) ->
    super
    @state.set tab: 'format', dest: 'FAKE DATA'
    @updateState()
    @listenTo @state, 'change:tab', @renderMain
    @listenTo @model, 'change', @updateState
    @query.count().then (c) => @model.set max: c
    @categoriseQuery()

  # This is probably slight overkill, and could be replaced
  # with a function at the cost of complexity.
  categoriseQuery: ->
    viewNodes = @query.getViewNodes()
    has = {}
    for type, table of @query.model.classes
      has[type] = _.any viewNodes, isa type
    @model.set {has}

  title: ->
    Messages.getText 'ExportTitle', {name: @query.name}

  primaryAction: -> Messages.getText 'ExportButton'

  body: Templates.template 'export_dialogue'

  updateState: ->
    {start, size, max, format, columns} = @model.toJSON()
    @state.set
      format: format
      rowCount: ((size or (max - start)) or max) # TODO: need a better calculation.
      columns: (columns.length || Messages.get('All'))

  getMain: ->
    switch @state.get('tab')
      when 'format' then FormatControls
      when 'columns' then ColumnControls
      when 'rows' then RowControls
      else FormatControls

  renderMain: ->
    Main = @getMain()
    @renderChild 'main', (new Main {@model, @query, @state}), @$ 'div.main'

  postRender: ->
    @renderChild 'menu', (new Menu {model: @state}), @$ 'nav.menu'
    @renderMain()
    super
