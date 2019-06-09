/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AdderButton;
const _ = require('underscore');
const CoreView = require('../../core-view');
const Messages = require('../../messages');
const PathModel = require('../../models/path');

require('../../messages/constraints');

module.exports = (AdderButton = (function() {
  AdderButton = class AdderButton extends CoreView {
    static initClass() {
  
      this.prototype.Model = PathModel;
    
      this.prototype.tagName = 'button';
  
      this.prototype.className = 'btn btn-primary im-add-constraint';
  
      this.prototype.optionalParameters = ['hideType'];
  
      this.prototype.hideType = false;
  }

    template(data) { return _.escape(Messages.getText('constraints.AddConFor', data)); }

    getData() { return _.extend(super.getData(...arguments), {hideType: this.hideType}); }

    modelEvents() { return {change: this.reRender}; }

    events() { return {click() { return this.trigger('chosen', this.model.get('path')); }}; }
};
  AdderButton.initClass();
  return AdderButton;
})());

