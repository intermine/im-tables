// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SummaryHeading;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

require('../../messages/summary');

module.exports = (SummaryHeading = (function() {
  SummaryHeading = class SummaryHeading extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-summary-heading';
  
      this.prototype.renderRequires = ['numeric', 'available', 'got', 'uniqueValues'];
  
      this.prototype.template = Templates.template('summary_heading');
  }

    modelEvents() { return {change: this.reRender, destroy: this.stopListening}; }
    stateEvents() { return {change: this.reRender}; }

    getData() { return _.extend(super.getData(...arguments), {filtered: (this.model.get('filteredCount') != null)}); }
};
  SummaryHeading.initClass();
  return SummaryHeading;
})());

