// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let CreateFromPath;
const {Promise} = require('es6-promise');

// Base class
const BaseCreateListDialogue = require('./base-dialogue');
const FromPathMixin = require('./from-path-mixin');

module.exports = (CreateFromPath = (function() {
  CreateFromPath = class CreateFromPath extends BaseCreateListDialogue {
    static initClass() {
  
      this.include(FromPathMixin(BaseCreateListDialogue));
    }
  };
  CreateFromPath.initClass();
  return CreateFromPath;
})());
