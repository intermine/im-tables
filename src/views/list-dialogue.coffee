_ = require 'underscore'

# Base class
Modal = require './modal'
# Text strings
Messages = require '../messages'

CreateListModel = require '../models/create-list'

ListDialogueBody = require './list-dialogue/body'

# This view uses the lists messages bundle.
require '../messages/lists'

module.exports = class CreateListDialogue extends Modal

  parameters: ['query', 'path']

  Model: CreateListModel

  Body: ListDialogueBody

  className: -> super + ' im-create-list'

  title: -> Messages.getText 'lists.CreateListTitle', @getData()

  primaryAction: -> Messages.getText 'lists.Create'

  act: ->
    toRun = @getQuery()
    toRun.saveAsList @model.toJSON()
         .then @resolve, (e) => @state.set error: e

  getQuery: -> @query.selectPreservingImpliedConstraints [@path]

  modelEvents: ->
    'change:type': 'setTypeName' # The type can change when selecting items

  # If the things that inform the title changes, replace it.
  stateEvents: ->
    'change:typeName change:count': 'setTitle'
    'change:typeName': 'setListName'
  
  setTitle: -> @$('.modal-title').text @title()

  setListName: ->
    @model.set name: Messages.getText 'lists.DefaultName', @state.toJSON()

  initState: ->
    @state.set minimised: _.result @, 'initiallyMinimised'
    @setTypeName()
    @setCount()
    @checkAuth()

  setCount: ->
    @query.summarise(@path)
          .then ({stats: {uniqueValues}}) => @state.set count: uniqueValues
          .then null, (e) => @state.set error: e

  setTypeName: ->
    @getType()?.getDisplayName()
               .then (typeName) => @state.set {typeName}
               .then null, (e) => @state.set error: e

  getType: ->
    @query.makePath @path
          .getParent()
          .getType()

  checkAuth: -> @getService().whoami().then null, =>
    @state.set error: {level: 'Error', key: 'lists.error.MustBeLoggedIn'}

  getService: -> @query.service

  postRender: ->
    super
    @renderChild 'body', (new this.Body {@model, @state}), @$ '.modal-body'

