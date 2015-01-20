{Promise} = require 'es6-promise'

# Base class
BaseAppendDialogue = require './base-append-dialogue'
FromPathMixin = require './from-path-mixin'

module.exports = class AppendFromPath extends BaseAppendDialogue

  @include FromPathMixin BaseAppendDialogue

