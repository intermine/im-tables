Backbone = require 'backbone'
_ = require 'underscore'

# HWAT! Do not be tempted to replace this with a loop to build DEFAULTS. That
# would break browserify. You would want to do that, would you?
actionMessages = require './messages/actions'
tableMessages = require './messages/table'
constraintMsgs = require './messages/constraints'
common = require './messages/common'

{numToString, pluralise} = require './templates/helpers'

DEFAULTS = [common, actionMessages, tableMessages, constraintMsgs]

HELPERS = # All message templates have access to these helpers.
  formatNumber: numToString
  pluralise: pluralise

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
      # also, allow users to supply precompiled or custom templates.
      templ = _.template(templ)
    @cache[key] = templ

  getText: (key, args = {}) =>
    templ = @getTemplate key
    # Make missing keys really obvious
    templ?(_.extend {Messages: @}, HELPERS, args) ? "!!!No message for #{ key }!!!"

  # Allows sets of messages to be set with a prefix namespacing them.
  setWithPrefix: (prefix, messages) -> for key, val of messages
    @set "#{prefix}.#{key}", val

  defaults: -> _.extend.apply null, [{}].concat DEFAULTS

module.exports = new Messages

module.exports.Messages = Messages
  
