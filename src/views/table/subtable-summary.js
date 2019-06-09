/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SubtableSummary;
const CoreView = require('../../core-view');
const Messages = require('../../messages');
const Templates = require('../../templates');

require('../../messages/subtables');

// This class serves to isolate re-draws to the summary so that they
// don't affect other sub-components.
module.exports = (SubtableSummary = (function() {
  SubtableSummary = class SubtableSummary extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-subtable-summary';
      this.prototype.tagName = 'span';
      this.prototype.template = Templates.template('table-subtable-summary');
  
      this.prototype.parameters = ['model', 'state'];
    }

    modelEvents() { return {'change:contentName': this.reRender}; }

    events() {
      return {click: this.onClick};
    }
    
    onClick(e) {
      if (e != null) {
        e.stopPropagation();
      }
      this.$el.tooltip('hide');
      return this.state.toggle('open');
    }

    postRender() { return this.$el.tooltip({
      title: (this.model.get('rows').length ? Messages.getText('subtables.OpenHint') : undefined),
      placement: 'auto right'
    }); }
  };
  SubtableSummary.initClass();
  return SubtableSummary;
})());
