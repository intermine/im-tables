Backbone = require 'backbone'
_ = require 'underscore'

class Messages extends Backbone.Model

  initialize: ->
    @cache = {}
    @on 'change', => @cache = {}

  destroy: ->
    @off()
    for prop of @
      delete @[prop]

  getTemplate: (key) ->
    templ = (@cache[key] ? @get key)
    if templ? and not templ.call?
      # Don't recompile the template each time
      templ = _.template(templ)
    @cache[key] = templ

  getText: (key, args) ->
    templ = @getTemplate key
    templ?(args)

  defaults: ->
    'Clear': 'Clear'
    'and': 'and'
    'or': 'or'
    'comma': ','
    'Cancel': 'Cancel'
    'export.DialogueTitle': 'Export'
    'constraints.AddNewFilter': 'Add New Filter'
    'constraints.AddFilter': 'Add filter'
    'modal.DefaultTitle': 'Excuse me...'
    'modal.Dismiss': 'Close'
    'modal.OK': 'OK'
    'largetable.ok': 'Set page size to <%- size %>'
    'largetable.abort': 'Cancel'
    'largetable.appeal': """
      You have requested a very large table size (<%= size %> rows per page). Your
      browser may struggle to render such a large table,
      and the page could become unresponsive. In any case,
      will be very difficult for you to read the whole table
      in the page. We suggest the following alternatives:
    """

module.exports = new Messages

module.exports.Messages = Messages
  
