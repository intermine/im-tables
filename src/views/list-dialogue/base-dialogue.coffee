_ = require 'underscore'

# Base class
Modal = require '../modal'
# Text strings
Messages = require '../../messages'

CreateListModel = require '../../models/create-list'
ListDialogueBody = require './body'

# This view uses the lists messages bundle.
require '../../messages/lists'

ABSTRACT = -> throw new Error 'not implemented'

module.exports = class BaseCreateListDialogue extends Modal

  # :: -> Promise<Query>
  getQuery: ABSTRACT

  # :: -> Promise<int>
  fetchCount: ABSTRACT

  # :: -> PathInfo?
  getType: ABSTRACT

  # :: -> Service
  getService: -> ABSTRACT

  Model: CreateListModel

  Body: ListDialogueBody

  className: -> super + ' im-list-dialogue im-create-list'

  title: -> Messages.getText 'lists.CreateListTitle', @getData()

  primaryAction: -> Messages.getText 'lists.Create'

  act: ->
    @getQuery().then (toRun) => @processQuery toRun
               .then @resolve, (e) => @state.set error: e

  verifyState: -> @state.set error: null

  processQuery: (query) -> query.saveAsList @model.toJSON()


  modelEvents: ->
    'change:type': 'onChangeType' # The type can change when selecting items

  onChangeType: -> @setTypeName()

  # If the things that inform the title changes, replace it.
  stateEvents: ->
    'change:typeName change:count': 'setTitle'
    'change:typeName': 'setListName'
    'change:error': -> console.log @state.get('error')
  
  setTitle: -> @$('.modal-title').text @title()

  setListName: ->
    @model.set name: Messages.getText 'lists.DefaultName', @state.toJSON()

  initState: ->
    @state.set existingLists: {}, minimised: _.result @, 'initiallyMinimised'
    @setTypeName()
    @setCount()
    @checkAuth()
    # you cannot overwrite your own lists. You can shadow everyone elses.
    @getService().fetchLists()
                 .then (ls) -> _.where ls, authorized: true
                 .then (ls) -> _.groupBy ls, 'name'
                 .then (existingLists) => @state.set {existingLists}

  setCount: ->
    @fetchCount().then (count) => @state.set count: count
                 .then null, (e) => @state.set error: e

  setTypeName: ->
    @getType()?.getDisplayName()
               .then (typeName) => @state.set {typeName}
               .then null, (e) => @state.set error: e

  checkAuth: -> @getService().whoami().then null, =>
    @state.set error: {level: 'Error', key: 'lists.error.MustBeLoggedIn'}

  getBodyOptions: -> {@model, @state}

  postRender: ->
    super
    @renderChild 'body', (new this.Body @getBodyOptions()), @$ '.modal-body'

