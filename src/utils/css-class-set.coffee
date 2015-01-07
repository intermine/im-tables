_ = require 'underscore'

module.exports = class ClassSet

  constructor: (@definitions) ->

  activeClasses: -> (cssClass for cssClass of @definitions when _.result @definitions, cssClass)

  toString: -> @activeClasses().join(' ')

