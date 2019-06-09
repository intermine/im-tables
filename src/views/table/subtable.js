/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SubTable;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Options = require('../../options');
const Collection = require('../../core/collection');
const Templates = require('../../templates');
const TypeAssertions = require('../../core/type-assertions');
const NestedTableModel = require('../../models/nested-table');
const PathModel = require('../../models/path');
const SubtableSummary = require('./subtable-summary');
const SubtableInner = require('./subtable-inner');

const {ignore} = require('../../utils/events');

class PathCollection extends Collection {
  static initClass() {
  
    this.prototype.model = PathModel;
  }
}
PathCollection.initClass();

const INITIAL_STATE = 'Subtables.Initially.expanded';

// A cell containing a subtable of other rows.
// The table itself can be expanded or collapsed.
// When collapsed it is represented by a summary line.
module.exports = (SubTable = (function() {
  SubTable = class SubTable extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'td';
  
      this.prototype.className = 'im-result-subtable';
  
      this.prototype.Model = NestedTableModel;
  
      this.prototype.parameters = [
        'query',
        'cellify',
        'expandedSubtables'
      ];
  
      this.prototype.parameterTypes = {
        query: TypeAssertions.Query,
        cellify: TypeAssertions.Function,
        expandedSubtables: TypeAssertions.Collection
      };
  
      this.prototype.template = Templates.template('table-subtable');
  
      this.prototype.tableRendered = false;
    }

    initialize() {
      super.initialize(...arguments);
      this.headers = new PathCollection;
      this.listenTo(this.expandedSubtables, 'add remove reset', this.onChangeExpandedSubtables);
      return this.buildHeaders();
    }

    // getPath is part of the RowCell API
    getPath() { return this.model.get('column'); }

    initState() {
      const open = (Options.get(INITIAL_STATE)) || (this.expandedSubtables.contains(this.getPath()));
      return this.state.set({open});
    }

    stateEvents() {
      return {'change:open': this.onChangeOpen};
    }

    onChangeOpen() {
      const wrapper = this.el.querySelector('.im-table-wrapper');
      if (this.state.get('open')) {
        if (this.renderTable(wrapper)) { // no point in sliding down unless this returned true.
          return this.$(wrapper).slideDown();
        }
      } else {
        return this.$(wrapper).slideUp();
      }
    }

    onChangeExpandedSubtables() {
      return this.state.set({open: this.expandedSubtables.contains(this.getPath())});
    }

    renderChildren() {
      this.renderChildAt('.im-subtable-summary', (new SubtableSummary({model: this.model, state: this.state})));
      return this.onChangeOpen();
    }

    // Render the table, and return true if there is anything to show.
    renderTable(wrapper) {
      const rows = this.model.get('rows');
      if (this.tableRendered || (rows.length === 0)) { return this.tableRendered; }
      const inner = new SubtableInner(_.extend({rows}, (_.pick(this, SubtableInner.prototype.parameters))));

      this.renderChild('inner', inner, wrapper);
      return this.tableRendered = true;
    }

    buildHeaders() {
      const [row] = Array.from(this.model.get('rows'));
      if (row == null) { return; } // No point building headers if the table is empty

      // Use the first row as a pattern.
      return this.headers.set(Array.from(row).map((c) => new PathModel(c.get('column'))));
    }
  };
  SubTable.initClass();
  return SubTable;
})());

