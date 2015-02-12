_ = require 'underscore'

CoreView = require '../../core-view'

buildSkipped   = require '../../utils/build-skipset'

module.exports = class TableBody extends CoreView

  tagName: 'tbody'

  parameters: ['makeCell', 'collection']

  collectionEvents: ->
    reset: @reRender
    add: @onRowAdded
    remove: @onRowRemoved
  
  template: ->

  renderChildren: ->
    if @collection.isEmpty()
      @handleEmptyTable()
    else
      frag = document.createDocumentFragment 'tbody'
      @collection.forEach (row) => @addRow row, frag
      @el.appendChild frag

  onRowAdded: (row) ->
    @removeChild 'apology'
    @addRow row

  onRowRemoved: (row) ->
    @removeChild row.id
    if @collection.isEmpty()
      @handleEmptyTable()

  addRow: (row, tbody) ->
    tbody ?= @el
    @renderChild row.id, (new RowView model: row, makeCell: @makeCell), tbody

  handleEmptyTable: ->
    @renderChild 'apology', new EmptyApology {@history}

class RowView extends CoreView

  tagName: 'tr'

  parameters: ['makeCell']

  postRender: ->
    cells = @model.get('cells').map @makeCell
    skipped = buildSkipped cells # TODO - cache result.
    for cell, i in cells when not skipped[cell.model.get('column')]
      @renderChild i, cell

class EmptyApology extends CoreView # pun fully intended ;)

  tagName: 'tr'

  className: 'im-empty-apology'

  template: Templates.template 'no-results'

  parameters: ['history']

  events: -> 'click .btn-undo': -> @history.popState()

  getData: -> _.extend super,
    selectList: @history.getCurrentQuery().views
    canUndo: (@history.length > 1)
