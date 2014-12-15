_ = require 'underscore'
fs = require 'fs'

Messages = require '../messages'
View = require '../core-view'

{Query, Model} = require 'imjs'

TEMPLATE = fs.readFileSync __dirname + '/../templates/constraint-summary.html', 'utf8'

module.exports = class ConstraintSummary extends View

  tagName: 'ol'

  className: 'summary breadcrumb'

  initialize: ->
    @listenTo @model, 'change', @reRender

  getData: -> messages: Messages, labels: @getSummary()

  template: _.template TEMPLATE

  getTitleOp: -> @model.get('op') or Messages.getText('IsA')

  getTitleVal: () ->
    if @model.get('values')
      @model.get('values').length + " values"
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
      labels.push({content: val, type: 'value'})

      if @isLookup() and @model.has 'extraValue'
        labels.push {content: @model.get('extraValue'), type: 'extra'}

    return labels
