Backbone = require 'backbone'
_ = require 'underscore'

# HWAT! Do not be tempted to replace this with a loop to build DEFAULTS. That
# would break browserify. You would want to do that, would you?
actionMessages = require './messages/actions'
tableMessages = require './messages/table'
constraintMsgs = require './messages/constraints'
summaryMessages = require './messages/summary'
common = require './messages/common'

{numToString} = require './templates/helpers'

DEFAULTS = [common, actionMessages, tableMessages, constraintMsgs, summaryMessages]

HELPERS = # All message templates have access to these helpers.
  formatNumber: numToString

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

  getText: (key, args = {}) =>
    templ = @getTemplate key
    # Make missing keys really obvious
    templ?(_.extend {}, HELPERS, args) ? "!!!No message for #{ key }!!!"

  defaults: -> _.extend.apply [{}].concat DEFAULTS

module.exports = new Messages

module.exports.Messages = Messages
  
