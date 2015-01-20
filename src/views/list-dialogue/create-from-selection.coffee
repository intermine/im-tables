_ = require 'underscore'
{Promise} = require 'es6-promise'

# Base class
BaseCreateListDialogue = require './base-dialogue'

# Mixins
Floating = require '../../mixins/floating-dialogue'

NO_COMMON_TYPE =
  level: 'Error'
  key: 'lists.NoCommonType'
  cannotDismiss: true

NO_OBJECTS_SELECTED =
  level: 'Info'
  key: 'lists.NoObjectsSelected'
  cannotDismiss: true

module.exports = class CreateFromSelection extends BaseCreateListDialogue

  @include Floating

  parameters: ['service', 'collection']

  className: 'modal im-list-picker im-create-list'

  # The abstract members of BaseCreateListDialogue

  # :: -> Promise<Query>
  getQuery: -> @service.query
    from: @model.get 'type'
    select: ['id']
    where: [{path: @model.get('type'), op: 'IN', ids: @getIds()}]
 
  # :: -> Promise<int>
  # The count is the number of ids, which we know statically.
  fetchCount: -> Promise.resolve @collection.size()

  # :: -> PathInfo?
  getType: -> @schema?.makePath(@model.get 'type') if @model.get 'type'

  # :: -> Service
  getService: -> @service

  # Our private implementation.
  collectionEvents: ->
    'add remove': @onChangeCollection

  initiallyMinimised: true

  initState: ->
    super
    @fetchModel().then => @setType()

  fetchModel: -> # call it schema to distinguish from model
    @service.fetchModel().then (model) => @schema = model

  getIds: -> @collection.map (o) -> o.get('id')

  onChangeCollection: ->
    @setCount()
    @setType()

  # Finds the common type from the collection, and sets that on the model.
  setType: ->
    return unless @schema? # have to wait until we have a model.
    unless @collection.size() # No objects -> no types.
      return @state.set error: NO_OBJECTS_SELECTED
    types = @collection.map (o) -> o.get 'class'
    commonType = @schema.findCommonType types
    if commonType
      @model.set type: commonType
      @state.set error: null
    else
      @model.set type: null
      @state.set error: NO_COMMON_TYPE
      @state.unset 'typeName'

