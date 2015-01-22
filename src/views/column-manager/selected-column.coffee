_ = require 'underscore'

CoreView = require '../../core-view'
Collection = require '../../core/collection'
Templates = require '../../templates'

PathModel = require '../../models/path'

module.exports = class SelectedColumn extends CoreView

  Model: PathModel

  tagName: 'li'

  className: 'list-group-item im-selected-column'

  modelEvents: ->
    'change:displayName': 'resetParts'

  template: Templates.template 'column-manager-selected-column'

  getData: ->
    isLast = (@model is @model.collection.last())
    _.extend super, isLast: isLast, parts: (@parts.map (p) -> p.get 'part')

  initialize: ->
    super
    @parts = new Collection
    @listenTo @parts, 'add remove reset', @reRender
    @resetParts()
    @listenTo @model.collection, 'sort', @reRender

  resetParts: -> if @model.get 'displayName'
    @parts.reset({part, id} for part, id in @model.get('displayName').split(' > '))

  postRender: ->
    # Activate tooltips.
    @$('[title]').tooltip container: @$el

  events: ->
    'click .im-remove-view': 'removeView'
    'binned': 'removeView'

  removeView: ->
    @model.collection.remove @model
    @model.destroy()
