// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Dashboard;
const _ = require('underscore');
const CoreView = require('../core-view');

const History         = require('../models/history');
const TableModel      = require('../models/table');
const SelectedObjects = require('../models/selected-objects');
const {Bus}           = require('../utils/events');
const Children        = require('../utils/children');
const Types           = require('../core/type-assertions');

const Table      = require('./table');
const QueryTools = require('./query-tools');

const ERR = 'Bad arguments to Dashboard - {query :: imjs.Query} is required';
const CC_NOT_FOUND = 'consumerContainer provided as selector - but no matching element was found';

module.exports = (Dashboard = (function() {
  Dashboard = class Dashboard extends CoreView {
    static initClass() {
  
      this.prototype.tagName = 'div';
  
      this.prototype.className = 'imtables-dashboard container-fluid';
  
      this.prototype.Model = TableModel;
  
      // :: Element or jQuery-ish or String
      this.prototype.optionalParameters = ['consumerContainer', 'consumerBtnClass'];
    }

    initialize({query}) {
      if (!Types.Query.test(query)) {
        if (query == null) { throw new Error(ERR); }
      }
      super.initialize(...arguments);
      this.history = new History;
      this.bus = new Bus;
      this.history.setInitialState(query);
      this.selectedObjects = new SelectedObjects(query.service);
      // Lift selector to element if provided as such.
      if ((this.consumerContainer != null) && _.isString(this.consumerContainer)) {
        this.consumerContainer = document.querySelector(this.consumerContainer);
        // If not found then log a message, but do not fail.
        if (!this.consumerContainer) { return console.log(CC_NOT_FOUND); }
      }
    }

    renderChildren() {
      this.renderQueryTools();
      return this.renderTable();
    }

    renderTable() {
      const table = Children.createChild(this, Table);
      return this.renderChild('table', table);
    }

    renderQueryTools() {
      const tools = Children.createChild(this, QueryTools, {tableState: this.model});
      return this.renderChild('tools', tools);
    }

    remove() {
      this.bus.destroy();
      this.history.close();
      return super.remove(...arguments);
    }
  };
  Dashboard.initClass();
  return Dashboard;
})());
