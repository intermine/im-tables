_ = require 'underscore'

CoreView = require '../../core-view'
CoreModel = require '../../core-model'
Collection = require '../../core/collection'
Templates = require '../../templates'

ClassSet = require '../../utils/css-class-set'

# The four dialogues of the apocalypse
AppendPicker = require './append-from-selection'
CreatePicker = require './create-from-selection'
AppendFromPath = require './append-from-path'
CreateFromPath = require './create-from-path'

require '../../messages/lists'

class PathModel extends CoreModel

  defaults: ->
    displayName: null
    path: null

  constructor: (path) ->
    super()
    @set id: path.toString(), path: path.toString()
    path.getDisplayName().then (name) => @set displayName: name

class Paths extends Collection

  model: PathModel

class SelectableNode extends CoreView

  tagName: 'li'

  RERENDER_EVENT: 'change:displayName'

  Model: PathModel

  template: Templates.template 'list-dialogue-button-node'

module.exports = class ListDialogueButton extends CoreView

  tagName: 'div'

  className: 'btn-group list-dialogue-button'

  template: Templates.template 'list-dialogue-button'

  parameters: ['query', 'selected']

  initState: ->
    @state.set action: 'create'

  stateEvents: ->
    'change:action': @setActionButtonState

  events: ->
    'click .im-create-action': @setActionIsCreate
    'click .im-append-action': @setActionIsAppend
    'click .im-pick-items': @startPicking

  initialize: ->
    super
    @initBtnClasses()
    @paths = new Paths
    # Reversed, because we prepend them in order to the menu.
    @query.getQueryNodes().reverse().forEach (n) => @paths.add new PathModel n

  getData: -> _.extend super, @classSets, paths: @paths.toJSON()

  postRender: ->
    menu = @$ '.dropdown-menu'
    @paths.each (pathModel, i) =>
      @renderChild "path-#{ i }", (new SelectableNode model: pathModel), menu, 'prepend'

  setActionIsCreate: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @state.set action: 'create'

  setActionIsAppend: (e) ->
    e.stopPropagation()
    e.preventDefault()
    @state.set action: 'append'

  startPicking: ->
    action = @state.get 'action'
    args = {collection: @selected, service: @query.service}
    console.log 'Lets get picking!', action
    try
      dialogue = switch action
        when 'append' then new AppendPicker args
        when 'create' then new CreatePicker args
        else throw new Error "Unknown action: #{ action }"
      @renderChild 'dialogue', dialogue
      success = (list) => @trigger "list:#{ action }", list
      failure = (e) => @trigger "failure:#{ action }", e
      dialogue.show().then success, failure
    catch e
      @state.set error: e

  setActionButtonState: ->
    action = @state.get 'action'
    @$('.im-create-action').toggleClass 'active', action is 'create'
    @$('.im-append-action').toggleClass 'active', action is 'append'

  initBtnClasses: ->
    @classSets = {}
    @classSets.createBtnClasses = new ClassSet
      'im-create-action': true
      'btn btn-default': true
      active: => @state.get('action') is 'create'
    @classSets.appendBtnClasses = new ClassSet
      'im-append-action': true
      'btn btn-default': true
      active: => @state.get('action') is 'append'

