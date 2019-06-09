// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let NoResults;
const CoreView = require('../../core-view');
const Templates = require('../../templates');

require('../../messages/summary');

// What we display when we display only one thing.
module.exports = (NoResults = (function() {
  NoResults = class NoResults extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-no-results';
  
      this.prototype.renderRequires = ['pathName'];
  
      this.prototype.template = Templates.template('summary_no_results');
  }

    stateEvents() {
      return {'change:pathName': this.reRender};
  }
};
  NoResults.initClass();
  return NoResults;
})());
