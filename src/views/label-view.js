/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let LabelView;
const View = require('../core-view');

// Base class for various labels.
module.exports = (LabelView = (function() {
  LabelView = class LabelView extends View {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change';
  
      this.prototype.tagName = 'span';
  }
};
  LabelView.initClass();
  return LabelView;
})());

