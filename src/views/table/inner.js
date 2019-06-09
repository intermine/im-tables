/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ResultsTable;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Formatting = require('../../formatting');
const PathSet = require('../../models/path-set');
const ColumnHeaders = require('../../models/column-headers');
const PopoverFactory = require('../../utils/popover-factory');
const History = require('../../models/history');
const TableModel = require('../../models/table');
const SelectedObjects = require('../../models/selected-objects');
const Preview = require('../item-preview');
const Types = require('../../core/type-assertions');
const CellFactory = require('./cell-factory');
const TableBody = require('./body');
const TableHead = require('./head');

// Flip the order of arguments.
const flip = f => (x, y) => f(y, x);

// Inner class that only knows how to render results,
// but not where they come from.
// Also, this is actually a table, with just headers and body.
// Mostly, this class just serves to pass arguments to the children.
module.exports = (ResultsTable = (function() {
  ResultsTable = class ResultsTable extends CoreView {
    constructor(...args) {
      {
        // Hack: trick Babel/TypeScript into allowing this before super.
        if (false) { super(); }
        let thisFn = (() => { return this; }).toString();
        let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
        eval(`${thisName} = this;`);
      }
      this.canUseFormatter = this.canUseFormatter.bind(this);
      super(...args);
    }

    static initClass() {
  
      this.prototype.className = "im-results-table table table-striped table-bordered";
  
      this.prototype.tagName = 'table';
  
      this.prototype.throbber = Templates.template('table-throbber');
  
      this.prototype.parameters = [
        'history',
        'columnHeaders',
        'rows',
        'tableState',
        'blacklistedFormatters',
        'selectedObjects',
      ];
  
      this.prototype.parameterTypes = {
        history: (Types.InstanceOf(History, 'History')),
        blacklistedFormatters: Types.Collection,
        rows: Types.Collection,
        tableState: (Types.InstanceOf(TableModel, 'TableModel')),
        columnHeaders: (Types.InstanceOf(ColumnHeaders, 'ColumnHeaders')),
        selectedObjects: (Types.InstanceOf(SelectedObjects, 'SelectedObjects'))
      };
  
      // Retrieve a formatter for a given leaf cell. Used by the cell factory.
      this.prototype.getFormatter = flip(Formatting.getFormatter);
    }

    initialize() {
      super.initialize(...arguments);
      const {service} = (this.query = this.history.getCurrentQuery());
      this.expandedSubtables = new PathSet; // Owned by the table, used by CellFactory
      this.popoverFactory = new PopoverFactory(service, Preview);
      this.cellFactory = CellFactory(service, this);

      this.listenTo(this.blacklistedFormatters, 'reset add remove', this.renderBody);
      return this.listenTo(this.history, 'changed:current', this.setQuery);
    }
    
    // We need to maintain the query reference as it is part of the
    // contract of the cell-factory.
    setQuery() { return this.query = this.history.getCurrentQuery(); }

    // can be used if it exists and hasn't been black-listed.
    // Used by the cell factory (hence bound)
    canUseFormatter(formatter) {
      return (formatter != null) && (!this.blacklistedFormatters.findWhere({formatter}));
    }

    renderChildren() {
      this.renderHeaders();
      return this.renderBody();
    }

    // Add headers to the table
    renderHeaders() {
      return this.renderChild('head', new TableHead((_.pick(this, TableHead.prototype.parameters))));
    }

    renderBody() { return this.renderChild('body', new TableBody({
      collection: this.rows,
      history: this.history,
      makeCell: this.cellFactory
    })
    ); }

    // Clean up resources we control.
    remove() {
      this.expandedSubtables.close();
      delete this.expandedSubtables;
      this.popoverFactory.destroy();
      delete this.popoverFactory;
      delete this.cellFactory;
      return super.remove(...arguments);
    }
  };
  ResultsTable.initClass();
  return ResultsTable;
})());

