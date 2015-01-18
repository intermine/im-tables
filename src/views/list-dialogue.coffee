_ = require 'underscore'
{Promise} = require 'es6-promise'

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

# Sub-components
InputWithButton = require '../core/input-with-button'
ListTag = require './list-dialogue/tag'
TagsApology = require './list-dialogue/tags-apology'
InputWithLabel = require '../core/input-with-label'

# This view uses the lists messages bundle.
require '../messages/lists'

class ModalBody extends CoreView

  Model: CreateListModel

  template: Templates.template 'list-dialogue-body'

  getData: -> _.extend super, @classSets

  modelEvents: -> 'add:tag': 'addTag'

  $tags: null # cache the .im-active-tags selector here

  postRender: -> # Render child views.
    @renderListNameInput()
    @renderListDescInput()
    @renderTags()

  renderTags: ->
    @$tags = @$ '.im-active-tags'
    @addTags()
    @renderApology()
    @renderTagAdder()

  renderTagAdder: ->
    nextTagView = new InputWithButton
      model: @model
      placeholder: 'lists.AddTag'
      button: 'lists.AddTagBtn'
      sets: 'nextTag'
    @listenTo nextTagView, 'act', @addNextTag
    @renderChildAt '.im-next-tag', nextTagView

  addTags: -> @model.tags.each (t) => @addTag t

  addTag: (t) -> if @rendered
    @renderChild "tag-#{ t.get 'id' }", (new ListTag model: t), @$tags

  renderApology: ->
    @renderChildAt '.im-apology', (new TagsApology collection: @model.tags)

  renderListNameInput: -> @renderChildAt '.im-list-name', new InputWithLabel
    model: @model
    attr: 'name'
    label: 'lists.params.Name'
    helpMessage: 'lists.params.help.Name'
    placeholder: 'lists.params.NamePlaceholder'
    getProblem: (name) -> not name?.length

  renderListDescInput: -> @renderChildAt '.im-list-desc', new InputWithLabel
    model: @model
    attr: 'desc'
    label: 'lists.params.Desc'
    placeholder: 'lists.params.DescPlaceholder'

  # DOM->model data-flow.

  addNextTag: -> @model.addTag()

module.exports = class CreateListDialogue extends Modal

  Model: CreateListModel

  className: -> super + ' im-create-list'

  title: -> Messages.getText 'lists.CreateListTitle', @getData()

  primaryAction: -> Messages.getText 'lists.Create'

  parameters: ['query', 'path']

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
    @setTypeName()
    @setCount()
    @checkAuth()

  setCount: ->
    @query.summarise(@path)
          .then ({stats: {uniqueValues}}) => @state.set count: uniqueValues
          .then null, (e) => @state.set error: e

  setTypeName: ->
    @query.makePath @path
          .getParent()
          .getType()
          .getDisplayName()
          .then (typeName) => @state.set {typeName}
          .then null, (e) => @state.set error: e

  checkAuth: ->
    @query.service.whoami().then null, =>
      @state.set error: {level: 'Error', key: 'lists.error.MustBeLoggedIn'}

  postRender: ->
    super
    @renderChild 'body', (new ModalBody {@model}), @$ '.modal-body'

