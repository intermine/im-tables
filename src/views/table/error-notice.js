_ = require 'underscore'
imjs = require 'imjs'

Options = require '../../options'
CoreView = require '../../core-view'
Templates = require '../../templates'
Messages = require '../../messages'
indentXML = require '../../utils/indent-xml'
mailto = require '../../utils/mailto'
withResource = require '../../utils/with-cdn-resource'
VERSION = require '../../version'

require '../../messages/error'

withPrettyPrintOne = _.partial withResource, 'prettify', 'prettyPrintOne'

getDomain = (err) ->
  if /(Type|Reference)Error/.test String err
    'client' # clearly our fault.
  else
    'server'

module.exports = class ErrorNotice extends CoreView

  className: 'im-error-notice'

  parameters: ['model', 'query']

  helpers: -> _.extend super, indent: indentXML

  template: Templates.template 'table-error'

  getData: ->
    err = @model.get('error')
    time = new Date()
    subject = Messages.getText('error.mail.Subject')
    address = @query.service.help
    domain = getDomain err

    # Make sure this error is logged.
    console.error err

    href = mailto.href address, subject, """
      We encountered an error running a query from an
      embedded result table.
      
      page:       #{ global.location }
      service:    #{ @query.service.root }
      error:      #{ err }
      date-stamp: #{ time }

      -------------------------------
      IMJS:       #{ imjs.VERSION }
      -------------------------------
      IMTABLES:   #{ VERSION }
      -------------------------------
      QUERY:      #{ @query.toXML() }
      -------------------------------
      STACK:      #{ err?.stack }
    """

    _.extend super, {domain, mailto: href, query: @query.toXML()}

  postRender: ->
    query = indentXML @query.toXML()
    pre = @$ '.query-xml'
    withPrettyPrintOne (ppo) -> pre.html ppo _.escape query

  events: ->
    'click .im-show-query': ->
      @$('.query-xml').slideToggle()
      @$('.im-show-query').toggleClass 'active'
    'click .im-show-error': ->
      @$('.error-message').slideToggle()
      @$('.im-show-error').toggleClass 'active'
