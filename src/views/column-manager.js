/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ColumnManager;
const _ = require('underscore');

const Modal = require('./modal');

const Templates = require('../templates');
const Messages = require('../messages');
const Collection = require('../core/collection');
const PathModel = require('../models/path');
const ColumnManagerTabs = require('./column-manager/tabs');
const SelectListEditor = require('./column-manager/select-list');
const SortOrderEditor = require('./column-manager/sort-order');
const AvailableColumns = require('../models/available-columns');
const OrderByModel = require('../models/order-element');

require('../messages/columns');

// Requires ::modelFactory
class IndexedCollection extends Collection {
  static initClass() {
  
    this.prototype.comparator = 'index';
  
    this.prototype.modelFactory = Collection.prototype.model;
  }

  add() {
    return super.add(...arguments);
  }

  constructor() {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { return this; }).toString();
      let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
      eval(`${thisName} = this;`);
    }
    this.model = this.model.bind(this);
    super(...arguments);
    this.listenTo(this, 'change:index', function() { return _.defer(() => this.sort()); }); // by default, make a model.
  }

  model(args) {
    const index = this.size();
    const model = new this.modelFactory(args);
    model.collection = this;
    model.set({index});
    return model;
  }
}
IndexedCollection.initClass();

class SelectList extends IndexedCollection {
  static initClass() {
  
    this.prototype.modelFactory = PathModel;
  }
}
SelectList.initClass();

class OrderByList extends IndexedCollection {
  static initClass() {
  
    this.prototype.modelFactory = OrderByModel;
  }
}
OrderByList.initClass();

module.exports = (ColumnManager = (function() {
  ColumnManager = class ColumnManager extends Modal {
    static initClass() {
  
      this.prototype.parameters = ['query'];
    }

    modalSize() { return 'lg'; }

    className() { return super.className(...arguments) + ' im-column-manager'; }

    title() { return Messages.getText('columns.DialogueTitle'); }

    primaryAction() { return Messages.getText('columns.ApplyChanges'); }

    dismissAction() { return Messages.getText('Cancel'); }

    act() { if (!this.state.get('disabled')) {
      const {viewChanged, orderChanged} = this.state.pick('viewChanged', 'orderChanged');
      if (viewChanged && (!orderChanged)) {
        this.query.select(this.getCurrentView()); // select the current view.
      } else if (orderChanged && (!viewChanged)) {
        this.query.orderBy(this.getCurrentSortOrder()); // order by the new sort-order.
      } else {
        // Collect all the events and trigger them all at once.
        const opts = {silent: true, events: []};
        this.query.select(this.getCurrentView(), opts);
        this.query.orderBy(this.getCurrentSortOrder(), opts);
        this.query.trigger(opts.events.join(' '));
      }
      return this.resolve('changed');
    } }

    stateEvents() {
      return {
        'change:currentTab': this.renderTabContent,
        'change:adding': this.setDisabled
      };
    }

    initialize() {
      let path;
      let direction;
      super.initialize(...arguments);
      // Populate the select list and sort-order with the current state of the
      // query.
      this.selectList = new SelectList;
      this.rubbishBin = new SelectList;
      this.sortOrder = new OrderByList;
      this.availableColumns = new AvailableColumns;
      // Populate the view
      for (let v of Array.from(this.query.views)) {
        this.selectList.add(this.query.makePath(v));
      }
      // Populate the sort-order
      for ({path, direction} of Array.from(this.query.sortOrder)) {
        this.sortOrder.add({direction, path: this.query.makePath(path)});
      }

      // Find the relevant sort paths which are not in the sort order already.
      for (path of Array.from(this.getRelevantPaths())) {
        if (!this.sortOrder.get(path.toString())) {
          this.availableColumns.add(path, {sort: false});
        }
      }
      this.availableColumns.sort(); // sort once, when they are all added.

      this.listenTo(this.selectList, 'sort add remove', this.setDisabled);
      return this.listenTo(this.sortOrder, 'sort add remove', this.setDisabled);
    }

    getRelevantPaths() {
      // Relevant paths are all the attributes of all the inner-joined query nodes.
      return _.chain(this.query.getQueryNodes())
       .filter(n => !this.query.isOuterJoined(n))
       .map(n => (() => {
         const result = [];
         for (let cn of Array.from(n.getChildNodes())) {            if (cn.isAttribute() && (cn.end.name !== 'id')) {
             result.push(cn);
           }
         }
         return result;
       })() )
       .flatten()
       .value();
    }

    getCurrentView() { return this.selectList.pluck('path'); }

    getCurrentSortOrder() { return this.sortOrder.map(m => m.asOrderElement()); }

    setDisabled() {
      if (this.state.get('adding')) { return this.state.set({disabled: true}); } // cannot confirm while adding.
      const currentView = this.getCurrentView().join(' ');
      const initialView = this.query.views.join(' ');
      const currentSO = this.sortOrder.map( m => m.toOrderString()).join(' ');
      const initialSO = this.query.getSorting();
      const viewUnchanged = (currentView === initialView);
      const soUnchanged = (currentSO === initialSO);
      // if no changes, then disable, since there are no changes to apply.
      return this.state.set({
        viewChanged: (!viewUnchanged),
        orderChanged: (!soUnchanged),
        disabled: (viewUnchanged && soUnchanged)
      });
    }

    initState() { // open the dialogue with the default tab open, and main button disabled.
      return this.state.set({
        disabledReason: 'columns.NoChangesToApply',
        disabled: true,
        currentTab: ColumnManagerTabs.TABS[0]});
    }

    renderTabs() {
      return this.renderChild('tabs', (new ColumnManagerTabs({state: this.state})), this.$('.modal-body'));
    }

    renderTabContent() { if (this.rendered) {
      const main = (() => { switch (this.state.get('currentTab')) {
        case 'view': return new SelectListEditor({state: this.state, query: this.query, rubbishBin: this.rubbishBin, collection: this.selectList});
        case 'sortorder': return new SortOrderEditor({query: this.query, availableColumns: this.availableColumns, collection: this.sortOrder});
        default: throw new Error(`Cannot render ${ this.state.get('currentTab') }`);
      } })();
      return this.renderChild('main', main, this.$('.modal-body'));
    } }

    postRender() {
      super.postRender(...arguments);
      this.renderTabs();
      return this.renderTabContent();
    }

    remove() {
      this.selectList.close();
      this.rubbishBin.close();
      this.sortOrder.close();
      this.availableColumns.close();
      return super.remove(...arguments);
    }
  };
  ColumnManager.initClass();
  return ColumnManager;
})());




