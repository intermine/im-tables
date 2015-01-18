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

# This view uses the lists messages bundle.
require '../messages/lists'

class ModalBody extends CoreView

  Model: CreateListModel

  RERENDER_EVENT: 'change:listName'

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

  postRender: ->
    {tags} = @model
    @$tags = @$ '.im-active-tags'
    tags.each (t) => @addTag t
    @renderChildAt '.im-apology', (new TagsApology collection: tags)
    nextTagView = new InputWithButton
      model: @model
      placeholder: 'lists.AddTag'
      button: 'lists.AddTagBtn'
      sets: 'nextTag'
    @listenTo nextTagView, 'act', @addNextTag

    @renderChildAt '.im-next-tag', nextTagView

  addTag: (t) -> if @rendered
    @renderChild "tag-#{ t.get 'id' }", (new ListTag model: t), @$tags

  # DOM->model data-flow.

  events: ->
    'change .im-list-name': 'setListName'
    'change .im-list-desc': 'setListDesc'

  addNextTag: -> @model.addTag()

  setListName: (e) -> @model.set listName: e.target.value

  setListDesc: (e) -> @model.set listDesc: e.target.value

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

