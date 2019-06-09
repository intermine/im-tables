// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let UnselectedColumn;
const _ = require('underscore');

const SelectedColumn = require('./selected-column');
const Templates = require('../../templates');

const TEMPLATE_PARTS = [
  'column-manager-path-name',
  'column-manager-restore-path'
];

module.exports = (UnselectedColumn = (function() {
  UnselectedColumn = class UnselectedColumn extends SelectedColumn {
    static initClass() {
  
      this.prototype.template = Templates.templateFromParts(TEMPLATE_PARTS);
  
      this.prototype.restoreTitle = 'columns.RestoreColumn';
    }

    events() { // Same logic as remove - remove from collection.
      return {
        'click .im-restore-view': 'removeView',
        'click': 'toggleFullPath'
      };
    }

    getData() { return _.extend(super.getData(...arguments), {restoreTitle: this.restoreTitle}); }
  };
  UnselectedColumn.initClass();
  return UnselectedColumn;
})());


