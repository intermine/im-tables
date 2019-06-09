_ = require 'underscore'
CoreView = require '../../core-view'
Templates = require '../../templates'
ClassSet = require '../../utils/css-class-set'

require '../../messages/joins'

LINE_PARTS = [
  'join-style',
  'column-manager-path-name',
  'clear',
]

class BtnClasses extends ClassSet

  constructor: (model, style) -> super
    'btn btn-default': true
    active: -> style is model.get 'style'

otherStyle = (style) -> switch style
  when 'INNER' then 'OUTER'
  when 'OUTER' then 'INNER'
  else 'INNER' # We could throw an error here.

class Join extends CoreView

  tagName: 'li'

  className: 'list-group-item'

  template: Templates.templateFromParts LINE_PARTS

  modelEvents: ->
    'change:style change:parts': @reRender

  initialize: ->
    super
    @classSets =
      innerJoinBtn: new BtnClasses @model, 'INNER'
      outerJoinBtn: new BtnClasses @model, 'OUTER'

  getData: -> _.extend super, @classSets

  events: ->
    'click button': @onButtonClick

  onButtonClick: (e) ->
    return if /active/.test e.target.className
    @model.swap 'style', otherStyle

module.exports = class JoinManagerBody extends CoreView

  template: Templates.template 'join-manager-body'

  initState: ->
    @state.set explaining: false

  postRender: ->
    @$group = @$ '.list-group'
    @collection.each (m) => @addJoin m

  addJoin: (model) -> if @rendered
    @renderChild model.id, (new Join {model}), @$group

  removeJoin: (model) -> @removeChild model.id

  events: ->
    'click .alert-info strong': -> @state.toggle 'explaining'

  stateEvents: ->
    'change:explaining': @onChangeExplaining

  collectionEvents: ->
    add: @addJoin
    remove: @removeJoin
    sort: @reRender

  onChangeExplaining: -> if @rendered
    p = @$ '.alert-info p'
    meth = if @state.get('explaining') then 'slideDown' else 'slideUp'
    p[meth]()

