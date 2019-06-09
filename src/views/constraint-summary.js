_ = require 'underscore'

Messages = require '../messages'
Templates = require '../templates'
CoreView = require '../core-view'
{IS_BLANK} = require '../patterns'

{Query, Model} = require 'imjs'

Messages.set
  'consummary.IsA': 'is a'
  'consummary.NoValue': 'no value'

module.exports = class ConstraintSummary extends CoreView

  tagName: 'ol'

  className: 'constraint-summary breadcrumb'

  initialize: ->
    super
    @listenTo Messages, 'change', @reRender

  getData: -> _.extend super, labels: @getSummary()

  template: Templates.template 'constraint-summary'

  getTitleOp: -> @model.get('op') or Messages.getText('consummary.IsA')

  modelEvents: ->
    change: @reRender

  events: ->
    'click .label-path': -> @state.toggle 'showFullPath'

  stateEvents: ->
    'change:showFullPath': @toggleFullPath

  toggleFullPath: ->
    @$('.label-path').toggleClass 'im-show-full-path', !!@state.get('showFullPath')

  postRender: ->
    @toggleFullPath()

  getTitleVal: () ->
    if @model.has('values') and @model.get('op') in Query.MULTIVALUE_OPS.concat Query.RANGE_OPS
      if vals = @model.get('values')
        if vals.length is 1
          vals[0]
        else if vals.length is 0
          '[ ]'
        else if vals.length > 5
          vals.length + " values"
        else
          [first..., last] = vals
          "#{ first.join ', ' } and #{ last }"
    else if @model.has('value')
      @model.get('value')
    else
      @model.get('typeName') ? @model.get('type') # Ideally should use displayName

  isLookup: -> @model.get('op') is 'LOOKUP'

  getPathLabel: ->
    {title, displayName, path} = @model.toJSON()
    {content: String(title ? displayName ? path), type: 'path'}

  getSummary: ->
    labels = []

    labels.push @getPathLabel()

    if (op = @getTitleOp())
      labels.push {content: op, type: 'op'}

    unless @model.get('op') in Query.NULL_OPS
      val = @getTitleVal()
      if (not val? or IS_BLANK.test val)
        level = if @model.get('new') then 'warning' else 'error'
        labels.push content: 'NoValue', type: level
      else
        labels.push content: val, type: 'value'

      if @isLookup() and @model.has 'extraValue'
        labels.push {content: @model.get('extraValue'), type: 'extra', icon: 'ExtraValue'}

    return labels
