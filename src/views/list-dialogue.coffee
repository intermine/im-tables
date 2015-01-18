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

  modelEvents: ->
    'add:tag': 'addTag'

  initialize: ->
    super
    # construct the class sets
    @classSets =
      listNameClasses: new ClassSet
        'form-group': true
        'has-error': => not @model.get 'listName'

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
    attr: 'listName'
    label: 'lists.params.Name'
    helpMessage: 'lists.params.help.Name'
    placeholder: 'lists.params.NamePlaceholder'
    getProblem: (name) -> not name?.length

  renderListDescInput: -> @renderChildAt '.im-list-desc', new InputWithLabel
    model: @model
    attr: 'listDesc'
    label: 'lists.params.Desc'
    placeholder: 'lists.params.DescPlaceholder'

  # DOM->model data-flow.

  addNextTag: -> @model.addTag()

module.exports = class CreateListDialogue extends Modal

  Model: CreateListModel

  className: -> super + ' im-create-list'

  title: -> Messages.getText 'lists.CreateListTitle'

  primaryAction: -> Messages.getText 'lists.Create'

  initialize: ({@query}) -> super

  # Things that must be true.

  invariants: ->
    hasQuery: "No query"

  hasQuery: -> @query?

  postRender: ->
    super
    @renderChild 'body', (new ModalBody {@model}), @$ '.modal-body'

  remove: ->
    @model.destroy()
    super

