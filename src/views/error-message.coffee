_ = require 'underscore'
fs = require 'fs'

CoreView = require '../core-view'
Icons = require '../icons'
Templates = require '../templates'

module.exports = class ErrorMessage extends CoreView

  className: 'im-error-message'

  modelEvents: ->
    'change:error': @reRender

  getData: -> icons: Icons, error: @model.get('error')

  logError: ->
    if e = @model.get('error')
      console.error e, e.stack

  template: Templates.template 'error-message'
