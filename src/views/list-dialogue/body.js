_ = require 'underscore'

CoreView = require '../../core-view' # base
Templates = require '../../templates' # template
Messages = require '../../messages'
CreateListModel = require '../../models/create-list' # model

# Sub-components
InputWithLabel = require '../../core/input-with-label'
InputWithButton = require '../../core/input-with-button'
ListTag = require './tag'
TagsApology = require './tags-apology'

# This view uses the lists messages bundle.
require '../../messages/lists'

module.exports = class ListDialogueBody extends CoreView

  Model: CreateListModel

  template: Templates.template 'list-dialogue-body'

  getData: -> _.extend super

  modelEvents: -> 'add:tag': 'addTag'

  stateEvents: ->
    'change:minimised': 'toggleOptionalAttributes'

  events: -> 'click .im-more-options': => @state.toggle 'minimised'

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

  toggleOptionalAttributes: ->
    state = @state.toJSON()
    $attrs = @$ '.im-optional-attributes'
    if state.minimised
      $attrs.slideUp()
    else
      $attrs.slideDown()
    msg = Messages.getText 'lists.ShowExtraOptions', state
    @$('.im-more-options .msg').text msg

  renderApology: ->
    @renderChildAt '.im-apology', (new TagsApology collection: @model.tags)

  renderListNameInput: ->
    nameInput = new InputWithLabel
      model: @model
      attr: 'name'
      label: 'lists.params.Name'
      helpMessage: 'lists.params.help.Name'
      placeholder: 'lists.params.NamePlaceholder'
      getProblem: (name) => @validateName name
    @listenTo nameInput.state, 'change:problem', ->
      err = nameInput.state.get('problem')
      @state.set disabled: !!err
    @renderChildAt '.im-list-name', nameInput
    
  validateName: (name) ->
    trimmed = name?.replace /(^\s+|\s+$)/g, '' # Trim name
    (not trimmed) or (@state.get('existingLists')[trimmed])

  renderListDescInput: -> @renderChildAt '.im-list-desc', new InputWithLabel
    model: @model
    attr: 'description'
    label: 'lists.params.Desc'
    placeholder: 'lists.params.DescPlaceholder'

  # DOM->model data-flow.

  addNextTag: -> @model.addTag()


