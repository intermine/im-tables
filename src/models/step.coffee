_ = require 'underscore'
CoreModel = require '../core-model'

module.exports = class StepModel extends CoreModel

  toJSON: -> _.extend super, query: @get('query').toJSON()

