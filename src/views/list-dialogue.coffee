_ = require 'underscore'
{Promise} = require 'es6-promise'

# Base class
Modal = require './modal'
# Model base class
CoreModel = require '../core-model'
CoreView = require '../core-view'

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

class ModalBody extends CoreView

  RERENDER_EVENT: 'change:listName'

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

  setListName: (e) -> @model.set listName: e.target.value

  setListDesc: (e) -> @model.set listDesc: e.target.value

module.exports = class CreateListDialogue extends Modal

  Model: CreateListModel

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

