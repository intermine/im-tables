_ = require 'underscore'
$ = require 'jquery'

CoreView = require '../../core-view'
Templates = require '../../templates'

buildSkipped = require '../../utils/build-skipset'

require '../../messages/table'

module.exports = class TableBody extends CoreView

  tagName: 'tbody'

  parameters: ['makeCell', 'collection', 'history']

  collectionEvents: ->
    reset: @reRender
    add: @onRowAdded
    remove: @onRowRemoved
  
  template: ->

  initialize: ->
    super
    @_skipSets = {} # cache - one per table.

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
    skipped = @skipped row
    view = new RowView model: row, makeCell: @makeCell, skipped: skipped
    @renderChild row.id, view, tbody

  handleEmptyTable: ->
    @renderChild 'apology', new EmptyApology {@history}

  skipped: (row) -> # one of the uglier parts of the codebase.
    @_skipSets[row.get('query')] ?= do => # builds and throws away cells
      temps = row.get('cells').map @makeCell
      ret = buildSkipped temps
      temps.forEach (t) -> t.remove()
      return ret

class RowView extends CoreView

  tagName: 'tr'

  parameters: ['makeCell', 'skipped']

  postRender: ->
    cells = @model.get('cells').map @makeCell
    for cell, i in cells when not @skipped[cell.model.get('column')]
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
