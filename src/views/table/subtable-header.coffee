_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

module.exports = class SubtableHeader extends CoreView

  tagName: 'thead'

  template: Templates.template 'table-subtables-header'

  parameters: [
    'columnModel', # The model of the column we are on.
    'query', # Needed because we will need to remove views.
  ]

  initialize: ->
    super
    @listenTo @columnModel, 'change:columnName', @reRender

  collectionEvents: ->
    'add remove change:displayName': @reRender

  getData: -> _.extend super, @columnModel.pick('columnName')

  remove: ->
    delete @columnModel
    super

