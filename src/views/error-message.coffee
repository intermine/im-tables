_ = require 'underscore'
fs = require 'fs'

View = require '../core-view'
Icons = require '../icons'

html = fs.readFileSync __dirname + '/../templates/error-message.html', 'utf8'

module.exports = class ErrorMessage extends View

  className: 'im-error-message'

  initialize: ->
    @listenTo @model, 'change:error', @reRender
    @listenTo @model, 'change:error', @logError

  getData: -> icons: Icons, error: @model.get('error')

  logError: ->
    if e = @model.get('error')
      console.error e, e.stack

  template: _.template html
