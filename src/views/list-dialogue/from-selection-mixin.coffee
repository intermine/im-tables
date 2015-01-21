NO_COMMON_TYPE =
  level: 'Error'
  key: 'lists.NoCommonType'
  cannotDismiss: true

NO_OBJECTS_SELECTED =
  level: 'Info'
  key: 'lists.NoObjectsSelected'
  cannotDismiss: true

module.exports = (Base) ->

  parameters: ['service', 'collection']

  className: -> Base::className.call(@) + ' im-list-picker'

  # :: -> Promise<Query>
  getQuery: -> @service.query
    from: @model.get 'type'
    select: ['id']
    where: [{path: @model.get('type'), op: 'IN', ids: @getIds()}]
 
  # :: -> Promise<int>
  # The count is the number of ids, which we know statically.
  fetchCount: -> Promise.resolve @collection.size()

  # :: -> Table?
  getType: -> if @model.get 'type'
    @schema?.makePath(@model.get 'type').getType()

  # :: -> Service
  getService: -> @service

  # Our private implementation.
  collectionEvents: ->
    'add remove': @onChangeCollection

  initiallyMinimised: true

  initState: ->
    Base::initState.call @
    @fetchModel().then => @setType()

  fetchModel: -> # call it schema to distinguish from model
    @service.fetchModel().then (model) => @schema = model

  getIds: -> @collection.map (o) -> o.get('id')

  onChangeCollection: ->
    @setCount()
    @setType()

  onChangeType: ->
    Base::onChangeType.call @
    @verifyState()

  verifyState: ->
    Base::verifyState.call @
    if not @collection.size()
      @state.set error: NO_OBJECTS_SELECTED
    else if not @model.get 'type'
      @state.set error: NO_COMMON_TYPE

  # Finds the common type from the collection, and sets that on the model.
  setType: ->
    return unless @schema? # have to wait until we have a model.
    return unless @collection.size() # No objects -> no types.
    types = @collection.map (o) -> o.get 'class'
    commonType = @schema.findCommonType types
    if commonType
      @model.set type: commonType
    else
      @model.set type: null
      @state.unset 'typeName'

