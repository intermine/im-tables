_ = require 'underscore'
{Promise} = require 'es6-promise'

# Base class
Modal = require './modal'
# Model base class
CoreModel = require '../core-model'
CoreView = require '../core-view'
CoreCollection = require '../core/collection'

# Text strings
Messages = require '../messages'
# Configuration
Options = require '../options'
# Templating
Templates = require '../templates'
# CSS class helpers.
ClassSet = require '../utils/css-class-set'

# This view uses the lists messages bundle.
require '../messages/lists'

class CreateListModel extends CoreModel

  defaults: ->
    listName: null
    listDesc: null

  initialize: ->
    @tags = new CoreCollection
    if @has 'tags'
      @tags.reset( {id: tag} for tag in @get 'tags' )
    @listenTo @tags, 'destroy', (t) => @tags.remove t

  toJSON: -> _.extend super, tags: @tags.map (t) -> t.get 'id'

  addTag: ->
    tag = @get 'nextTag'
    throw new Error('No tag to add') unless tag?
    @tags.add {id: tag}
    @unset 'nextTag'
    @trigger 'add:tag', tag

  destroy: ->
    @tags.close()
    super

class ModalBody extends CoreView

  RERENDER_EVENT: 'change:listName add:tag'

  template: Templates.template 'list-dialogue-body'

  getData: -> _.extend super, @classSets

  initialize: ->
    super
    # construct the class sets
    @classSets =
      listNameClasses: new ClassSet
        'form-group': true
        'has-error': => not @model.get 'listName'

  # DOM->model data-flow.

  events: ->
    'change .im-list-name': 'setListName'
    'change .im-list-desc': 'setListDesc'
    'keyup .im-next-tag input': 'setNextTagContent'
    'click .im-next-tag button': 'addNextTag'

  addNextTag: -> @model.addTag()

  setNextTagContent: (e) -> @model.set nextTag: e.target.value

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

