_ = require 'underscore'
{Promise} = require 'es6-promise'

CoreCollection = require '../../core/collection'
CoreModel = require '../../core-model'
Messages = require '../../messages'

BaseCreateListDialogue = require './base-dialogue'

AppendToListBody = require './append-to-list-body'
AppendToListModel = require '../../models/append-to-list'

NO_SUITABLE_LISTS =
  key: 'lists.NoSuitableLists'
  level: 'Warning'
  cannotDismiss: true

LIST_NOT_SUITABLE =
  key: 'lists.TargetNotCorrectType'
  level: 'Error'
  cannotDismiss: true

TARGET_DOES_NOT_EXIST =
  key: 'lists.TargetDoesNotExist'
  level: 'Error'
  cannotDismiss: true

NO_TARGET_SELECTED =
  key: 'lists.NoTargetSelected'
  level: 'Info'
  cannotDismiss: true

theListIsSuitable = (path) -> (list) ->
  return (Promise.reject LIST_NOT_SUITABLE) unless (path.isa list.type)

onlyCurrent = (ls) -> _.where ls, status: 'CURRENT'

# Unpack list objects, taking only what we need.
unpackLists = (ls) -> ({name, type, size, id: name} for {name, type, size} in ls)

class PossibleList extends CoreModel

  defaults: ->
    typeName: null
    name: null
    size: 0

  initialize: ->
    super
    @fetchTypeName()

  fetchTypeName: ->
    s = @collection.service
    type = @get 'type'
    s.fetchModel().then (model) -> model.makePath(type)
                  .then (path) -> path.getDisplayName()
                  .then (name) => @set typeName: name

class PossibleLists extends CoreCollection

  model: PossibleList

  constructor: ({@service}) -> super()

module.exports = class BaseAppendDialogue extends BaseCreateListDialogue

  Body: AppendToListBody

  Model: AppendToListModel

  title: -> Messages.getText 'lists.AppendToListTitle', @getData()

  primaryAction: -> Messages.getText 'lists.Append'

  initialize: ->
    super
    @listenTo @getPossibleLists(), 'remove reset', @verifyState

  getPossibleLists: ->  @possibleLists ?= new PossibleLists service: @getService()

  processQuery: (query) -> query.appendToList @model.get 'target'
  
  modelEvents: -> _.extend super,
    'change:target': 'onChangeTarget'

  initState: ->
    super
    @fetchSuitableLists()
    @verifyState()

  checkThereAreLists: -> unless @getPossibleLists().size()
    @state.set error: NO_SUITABLE_LISTS

  onChangeTarget: ->
    @setTitle()
    @verifyState()

  verifyState: ->
    @state.unset 'error' # it will be set down the line.
    @checkThereAreLists()
    @verifyTarget()
    @verifyTargetExistsAndIsSuitable()

  verifyTarget: ->
    unless @model.get('target')
      @state.set error: NO_TARGET_SELECTED

  onChangeType: ->
    super
    @fetchSuitableLists()

  getBodyOptions: -> _.extend super, collection: @getPossibleLists()

  verifyTargetExistsAndIsSuitable: ->
    type = @getType()
    return unless type?
    target = @model.get 'target'
    return unless target?
    path = type.model.makePath type.name

    @getService().fetchList target
                 .then (theListIsSuitable path), (-> TARGET_DOES_NOT_EXIST)
                 .then null, (e) => @state.set error: e

  fetchSuitableLists: ->
    type = @getType()
    return @getPossibleLists().reset() unless type?

    path = type.model.makePath type.name

    @getService().fetchLists()
                 .then (lists) -> _.filter lists, (list) -> path.isa list.type
                 .then onlyCurrent
                 .then unpackLists
                 .then (ls) => @getPossibleLists().reset ls
                 .then null, (e) => @state.set error: e

