// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let CreateFromSelection;
const _ = require('underscore');
const {Promise} = require('es6-promise');

// Base class
const BaseCreateListDialogue = require('./base-dialogue');

// Mixins
const Floating = require('../../mixins/floating-dialogue');
const FromSelectionMixin = require('./from-selection-mixin');

module.exports = (CreateFromSelection = (function() {
  CreateFromSelection = class CreateFromSelection extends BaseCreateListDialogue {
    static initClass() {
  
      this.include(Floating);
  
      this.include(FromSelectionMixin(BaseCreateListDialogue));
  }
};
  CreateFromSelection.initClass();
  return CreateFromSelection;
})());

