_ = require 'underscore'
CoreView = require '../../core-view'
ColumnHeader = require './header'

module.exports = class TableHead extends CoreView

  tagName: 'thead'

  parameters: [
    'history',
    'expandedSubtables',
    'blacklistedFormatters',
    'columnHeaders',
  ]

  template: ->

  initialize: ->
    @listenTo @columnHeaders, 'add reset sort', @reRender
    @listenTo @columnHeaders, 'remove', (ch) -> @removeChild ch.id

  renderChildren: ->
    docfrag = document.createDocumentFragment()
    tr = document.createElement 'tr'
    docfrag.appendChild tr
    query = @history.getCurrentQuery()

    headerOpts = {query, @expandedSubtables, @blacklistedFormatters}

    @columnHeaders.each @renderHeader tr, headerOpts
            
    @$el.html docfrag

  # Render a single header to the row of headers
  renderHeader: (tr, opts) -> (model, i) =>
    header = new ColumnHeader _.extend {model}, opts
    @renderChild model.id, header, tr

