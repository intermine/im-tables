_ = require 'underscore'
CoreView = require '../../core-view'
Templates = require '../../templates'
ClassSet = require '../../utils/css-class-set'

require '../../messages/joins'

LINE_PARTS = [
  'column-manager-path-name',
  'join-style',
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

  tagName: 'ul'

  className: 'list-group'

  postRender: ->
    @collection.each (m) => @addJoin m

  addJoin: (model) -> if @rendered
    @renderChild model.id, (new Join {model})

  removeJoin: (model) -> @removeChild model.id

  collectionEvents: ->
    add: @addJoin
    remove: @removeJoin

