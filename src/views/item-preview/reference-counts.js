/*
 * decaffeinate suggestions:
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ReferenceCounts;
const Templates = require('../../templates');
const CoreView = require('../../core-view');

module.exports = (ReferenceCounts = (function() {
  ReferenceCounts = class ReferenceCounts extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-related-counts';
  
      this.prototype.tagName = 'ul';
  
      this.prototype.template = Templates.template('cell-preview-reference-relation');
  }

    collectionEvents() { return {'add change sort': this.reRender}; }
};
  ReferenceCounts.initClass();
  return ReferenceCounts;
})());
