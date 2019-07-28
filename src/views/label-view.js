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

