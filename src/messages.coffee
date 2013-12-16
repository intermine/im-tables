_ = require 'underscore'
defaults = require './messages/defaults'

MESSAGES = {}

for setName, msgSet of defaults
  for k, v of msgSet
    MESSAGES[setName + '.' + k] = v

exports.getMessage = (key) -> MESSAGES[key]

exports.registerMessage = (key, value) -> MESSAGES[key] = value

exports.getMessageSet = (prefix) ->
  prefix += '.'
  messages = {}
  test = (key) -> key.length > prefix.length and key.slice(0, prefix.length) is prefix
  for key, msg of MESSAGES when test key
    messages[key.slice(prefix.length)] = msg

  return messages

exports.registerMessages = (messages) ->
  if _.isArray(messages)
    for [k, v] in messages
      MESSAGES[k] = v
  else
    for k, v of messages
      MESSAGES[k] = v

exports.defaultMessages = (messages) ->
  for k, v of messages when not MESSAGES[k]
    MESSAGES[k] = v
