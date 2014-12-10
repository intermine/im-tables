Backbone = require 'backbone'
_ = require 'underscore'

class Messages extends Backbone.Model

  initialize: ->
    @cache = {}
    @on 'change', => @cache = {}

  getText: (key, args) ->
    templ = (@cache[key] ? @get key)
    if templ? and not templ.call?
      templ = _.template(templ)(args)
    @cache[key] = templ
    templ?(args)

module.exports = new Messages
  'largetable.ok': 'Set page size to <%= size %>'
  'largetable.abort': 'Cancel'

  
