_ = require 'underscore'
CoreModel = require '../core-model'

module.exports = class AppendToListModel extends CoreModel

  # This model has a target and a type.
  defaults: ->
    target: null
    type: null
    size: null
