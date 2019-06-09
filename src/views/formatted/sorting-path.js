// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SortedPath;
const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Icons = require('../../icons');

const sortQueryByPath = require('../../utils/sort-query-by-path');

const INITIAL_CARETS = /^\s*>\s*/;

// An individual path we can sort by.
module.exports = (SortedPath = (function() {
  SortedPath = class SortedPath extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'li';
  
      this.prototype.className = 'im-formatted-path im-subpath';
  
      // Inherits model and state from parent, but is specialised on @path
      this.prototype.parameters = ['query', 'path'];
  
      this.prototype.template = Templates.template('formatted_sorting');
  }

    stateEvents() { return {change: this.reRender}; }

    getData() { // Provides Icons, name, direction
      const names = this.state.toJSON();
      const name = names[this.path] != null ? names[this.path].replace(names.group, '')
                          .replace(INITIAL_CARETS, '') : undefined;
      const direction = this.query.getSortDirection(this.path);
      return {Icons, name, direction};
  }

    events() { return {click: 'sortByPath'}; }

    sortByPath() { return sortQueryByPath(this.query, this.path); }
};
  SortedPath.initClass();
  return SortedPath;
})());

