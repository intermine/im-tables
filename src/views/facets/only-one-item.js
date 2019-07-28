// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let OnlyOneItem;
const CoreView = require('../../core-view');
const Templates = require('../../templates');

// What we display when we display only one thing.
module.exports = (OnlyOneItem = (function() {
  OnlyOneItem = class OnlyOneItem extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-only-one';
  
      this.prototype.template = Templates.template('only_one_item');
    }

    modelEvents() { return {change: this.reRender}; }
    stateEvents() { return {change: this.reRender}; }
  };
  OnlyOneItem.initClass();
  return OnlyOneItem;
})());
