/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AppendFromPath;
const {Promise} = require('es6-promise');

// Base class
const BaseAppendDialogue = require('./base-append-dialogue');
const FromPathMixin = require('./from-path-mixin');

module.exports = (AppendFromPath = (function() {
  AppendFromPath = class AppendFromPath extends BaseAppendDialogue {
    static initClass() {
  
      this.include(FromPathMixin(BaseAppendDialogue));
    }
  };
  AppendFromPath.initClass();
  return AppendFromPath;
})());

