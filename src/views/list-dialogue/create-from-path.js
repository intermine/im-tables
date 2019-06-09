{Promise} = require 'es6-promise'

# Base class
BaseCreateListDialogue = require './base-dialogue'
FromPathMixin = require './from-path-mixin'

module.exports = class CreateFromPath extends BaseCreateListDialogue

  @include FromPathMixin BaseCreateListDialogue
