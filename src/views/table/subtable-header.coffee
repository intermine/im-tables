_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

require '../../messages/subtables'

class SubtableHeader extends CoreView

  tagName: 'th'

  parameters: ['columnModel', 'model', 'query']

  template: Templates.template 'table-subtables-header'

  getData: -> _.extend super, @columnModel.pick('columnName')

  modelEvents: -> 'change:displayName': @reRender

  events: -> 'click a': @removeView

  removeView: ->
    @query.removeFromSelect(@model.get('replaces') ? @model.get('path'))

  postRender: ->
    @$('[title]').tooltip()

  initialize: ->
    super
    @listenTo @columnModel, 'change:columnName', @reRender

  remove: ->
    delete @columnModel
    super

module.exports = class SubtableHeaders extends CoreView

  tagName: 'thead'

  template: -> '<tr></tr>'

  parameters: [
    'collection', # the column headers
    'columnModel', # The model of the column we are on.
    'query', # Needed because we will need to remove views.
  ]

  collectionEvents: ->
    'add remove': @reRender

  renderChildren: ->
    tr = @el.querySelector 'tr'
    @collection.forEach (model, i) =>
      @renderChild i, (new SubtableHeader {model, @query, @columnModel}), tr

  remove: ->
    delete @columnModel
    super

