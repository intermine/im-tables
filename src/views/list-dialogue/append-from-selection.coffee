{Promise} = require 'es6-promise'

# Base class
BaseAppendDialogue = require './base-append-dialogue'

# Mixins
Floating = require '../../mixins/floating-dialogue'
FromSelectionMixin = require './from-selection-mixin'

module.exports = class AppendFromSelection extends BaseAppendDialogue

  @include Floating

  @include FromSelectionMixin BaseAppendDialogue

