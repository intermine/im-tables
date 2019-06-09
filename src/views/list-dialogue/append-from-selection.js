/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AppendFromSelection;
const {Promise} = require('es6-promise');

// Base class
const BaseAppendDialogue = require('./base-append-dialogue');

// Mixins
const Floating = require('../../mixins/floating-dialogue');
const FromSelectionMixin = require('./from-selection-mixin');

module.exports = (AppendFromSelection = (function() {
  AppendFromSelection = class AppendFromSelection extends BaseAppendDialogue {
    static initClass() {
  
      this.include(Floating);
  
      this.include(FromSelectionMixin(BaseAppendDialogue));
  }
};
  AppendFromSelection.initClass();
  return AppendFromSelection;
})());

