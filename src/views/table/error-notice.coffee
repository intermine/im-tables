{param} = require 'jquery'
_ = require 'underscore'
imjs = require 'imjs'

Options = require '../../options'
CoreView = require '../../core-view'
Templates = require '../../templates'
indentXML = require '../../utils/indent-xml'
VERSION = require '../../version'

require '../../messages/error'

module.exports = class ErrorNotice extends CoreView

  className: 'im-error-notice'

  parameters: ['model', 'query']

  helpers: -> _.extend super, indent: indentXML

  template: Templates.template 'table-error'

  getData: ->
    err = @model.get('error')
    time = new Date()
    console.error(err, err?.stack)

    domain = if /(Type|Reference)Error/.test(String(err))
      'client' # clearly our fault.
    else
      'server'

    mailto = query.service.help + "?" + param {
      subject: "Error running embedded table query"
      body: """
        We encountered an error running a query from an
        embedded result table.
        
        page:       #{ window.location }
        service:    #{ query.service.root }
        error:      #{ err }
        date-stamp: #{ time }

        -------------------------------
        IMJS:       #{ imjs.VERSION }
        -------------------------------
        IMTABLES:   #{ VERSION }
        -------------------------------
        QUERY:      #{ query.toXML() }
        -------------------------------
        STACK:      #{ err?.stack }
      """
    }, true
    _.extend super, {domain, mailto, query: @query.toXML()}

  events: -> 'click button': -> @$('.query-xml').slideToggle()
