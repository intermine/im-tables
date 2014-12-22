_ = require 'underscore'
fs = require 'fs'

Messages = require '../messages'
View = require '../core-view'
Options = require '../options'

mustacheSettings = require '../templates/mustache-settings'

html = fs.readFileSync __dirname + '/../templates/boolean-value-controls.html', 'utf8'

module.exports = class BooleanValueControls extends View

  className: 'im-value-options btn-group'

  initialize: ->
    @listenTo @model, 'change', @reRender

  getData: -> _.extend {value: null}, super

  template: _.template html, mustacheSettings

  events: ->
    'click .im-true': 'setValueTrue'
    'click .im-false': 'setValueFalse'

  setValueTrue: -> @model.set value: true

  setValueFalse: -> @model.set value: false

