_ = require 'underscore'
{Promise} = require 'es6-promise'

# Base class
BaseCreateListDialogue = require './base-dialogue'

# Mixins
Floating = require '../../mixins/floating-dialogue'
FromSelectionMixin = require './from-selection-mixin'

module.exports = class CreateFromSelection extends BaseCreateListDialogue

  @include Floating

  @include FromSelectionMixin BaseCreateListDialogue

