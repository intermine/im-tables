_ = require 'underscore'

# Base class
Modal = require './modal'
# Model base class
CoreView = require '../core-view'

# Text strings
Messages = require '../messages'
# Configuration
Options = require '../options'
# Templating
Templates = require '../templates'
# CSS class helpers.
ClassSet = require '../utils/css-class-set'

CreateListModel = require '../models/create-list'
ListDialogue = require './list-dialogue'
ModalFooter = require './modal-footer'

# Sub-components

Floating = require '../mixins/floating-dialogue'

# This view uses the lists messages bundle.
require '../messages/lists'

NO_COMMON_TYPE =
  level: 'Error'
  key: 'lists.NoCommonType'
  cannotDismiss: true

NO_OBJECTS_SELECTED =
  level: 'Warning'
  key: 'lists.NoObjectsSelected'
  cannotDismiss: true

module.exports = class ListPickerDialogue extends ListDialogue

  @include Floating

  parameters: ['service']

  initState: ->
    super
    @fetchModel().then => @setType()

  footer: Templates.templateFromParts ['modal-error', 'modal-footer']

  fetchModel: -> # call it schema to distinguish from model
    @service.fetchModel().then (model) => @schema = model

  collectionEvents: ->
    'add remove': @onChangeCollection

  onChangeCollection: ->
    @setCount()
    @setType()

  # The count is the number of ids.
  setCount: -> @state.set count: @collection.size()

  # Returns the TypeInfo object for the current type. Or nothing.
  getType: ->
    @schema.makePath(@model.get 'type') if @model.get 'type'

  getService: -> @service

  # Finds the common type from the collection, and sets that on the model.
  setType: ->
    return unless @schema? # have to wait until we have a model.
    unless @collection.size() # No objects -> no types.
      return @state.set error: NO_OBJECTS_SELECTED
    types = @collection.map (o) -> o.get 'type'
    commonType = @schema.findCommonType types
    if commonType
      @model.set type: commonType
    else
      @model.set type: null, error: NO_COMMON_TYPE
      @state.unset 'typeName'

