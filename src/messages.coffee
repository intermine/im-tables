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
    'largetable.ok': 'Set page size to <%- size %>'
    'largetable.abort': 'Cancel'

module.exports = new Messages

module.exports.Messages = Messages
  
