_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

ClassSet = require '../../utils/css-class-set'

require '../../messages/lists'

module.exports = class ListDialogueButton extends CoreView

  tagName: 'div'

  className: 'btn-group list-dialogue-button'

  template: Templates.template 'list-dialogue-button'

  parameters: ['query']

  initialize: ->
    super
    @initBtnClasses()

  initState: ->
    @state.set action: 'create'

  getData: -> _.extend super, @classSets

  initBtnClasses: ->
    @classSets = {}
    @classSets.createBtnClasses = new ClassSet
      'btn btn-default': true
      active: => @state.get('action') is 'create'
    @classSets.appendBtnClasses = new ClassSet
      'btn btn-default': true
      active: => @state.get('action') is 'append'

