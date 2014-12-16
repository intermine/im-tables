_ = require 'underscore'
fs = require 'fs'

Messages = require '../messages'
Icons = require '../icons'
View = require '../core-view'
{IS_BLANK} = require '../patterns'

{Query, Model} = require 'imjs'

Messages.set
  'consummary.IsA': 'is a'
  'consummary.NoValue': 'no value'

TEMPLATE = fs.readFileSync __dirname + '/../templates/constraint-summary.html', 'utf8'

module.exports = class ConstraintSummary extends View

  tagName: 'ol'

  className: 'summary breadcrumb'

  initialize: ->
    @listenTo @model, 'change', @reRender
    @listenTo Messages, 'change', @reRender
    @listenTo Icons, 'change', @reRender

  getData: -> icons: Icons, messages: Messages, labels: @getSummary()

  template: _.template TEMPLATE

  getTitleOp: -> @model.get('op') or Messages.getText('consummary.IsA')

  getTitleVal: () ->
    if vals = @model.get('values')
      if vals.length > 5
        vals.length + " values"
      else
        [first..., last] = vals
        "#{ first.join ', ' } and #{ last }"
    else if @model.has('value')
      @model.get('value')
    else
      @model.get('typeName') ? @model.get('type') # Ideally should use displayName

  isLookup: -> @model.get('op') is 'LOOKUP'

  getSummary: ->
    labels = []

    title = if (@model.has 'title') then @model.get('title') else @model.get('displayName')
    labels.push {content: title, type: 'path'}

    if (op = @getTitleOp())
      labels.push {content: op, type: 'op'}

    unless @model.get('op') in Query.NULL_OPS
      val = @getTitleVal()
      if (not val? or IS_BLANK.test val)
        labels.push content: 'NoValue', type: 'error'
      else
        labels.push content: val, type: 'value'

      if @isLookup() and @model.has 'extraValue'
        labels.push {content: @model.get('extraValue'), type: 'extra', icon: 'ExtraValue'}

    return labels
