// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let TableSummary;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

require('../../messages/table');

module.exports = (TableSummary = (function() {
  TableSummary = class TableSummary extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-table-summary hidden-phone';
  
      this.prototype.RERENDER_EVENT = 'change:start change:size change:count';
  
      this.prototype.template =  Templates.template('count_summary');
    }

    getData() {
      let data;
      const {start, size, count} = (data = super.getData(...arguments));
      return _.extend(data, { page: {
        count,
        first: start + 1,
        last: (size === 0) ? 0 : Math.min(start + size, count)
      }
    }
      );
    }
  };
  TableSummary.initClass();
  return TableSummary;
})());
