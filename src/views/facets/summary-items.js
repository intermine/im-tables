// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SummaryItems;
const _ = require('underscore');
const Backbone = require('backbone');

const CoreView = require('../../core-view');
const Templates = require('../../templates');
const Messages = require('../../messages');
const SetsPathNames = require('../../mixins/sets-path-names');

const SummaryItemsControls = require('./summary-items-controls');
const FacetRow = require('./row');

require('../../messages/summary');

// Null safe event ignorer, and blocker.
const IGNORE = function(e) { if (e != null) {
  e.preventDefault();
  return e.stopPropagation();
} };

const rowId = model => `row_${ model.get('id') }`;

module.exports = (SummaryItems = (function() {
  SummaryItems = class SummaryItems extends CoreView {
    constructor(...args) {
      super(...args);
      this.filterItems = this.filterItems.bind(this);
    }

    static initClass() {
  
      this.include(SetsPathNames);
  
      this.prototype.tagName = 'div';
  
      this.prototype.className = 'im-summary-items';
  
      // The template, and data used by templates
  
      this.prototype.template = Templates.template('summary_items');
  
      this.prototype.colClasses = ['im-item-selector', 'im-item-value', 'im-item-count'];
    }

    stateEvents() { return {'change:error': this.setErrOnModel}; }

    setErrOnModel() { return this.model.set(this.state.pick('error')); }

    initialize() {
      super.initialize(...arguments);
      this.listenTo(this.model.items, 'add', this.addItem);
      this.listenTo(this.model.items, 'remove', this.removeItem);
      this.listenTo(this.state, 'change:typeName change:endName', this.reRender);
      return this.setPathNames();
    }

    // Things we need before we can start.
    invariants() {
      return {
        modelHasItems: `expected a SummaryItems model, got: ${ this.model }`,
        modelCanHasMore: `expected the correct model methods, got: ${ this.model }`
      };
    }

    modelHasItems() { return (this.model != null ? this.model.items : undefined) instanceof Backbone.Collection; }

    modelCanHasMore() { return _.isFunction(this.model != null ? this.model.hasMore : undefined); }
 
    getData() { return _.extend(super.getData(...arguments), {
      hasMore: this.model.hasMore(),
      colClasses: (_.result(this, 'colClasses')),
      colHeaders: (_.result(this, 'colHeaders'))
    }
    ); }

    colHeaders() {
      const itemColHeader = this.state.has('typeName') ?
        `${ this.state.get('typeName') } ${ this.state.get('endName') }`
      :
        Messages.getText('summary.Item');

      return [' ', itemColHeader, (Messages.getText('summary.Count'))];
    }

    // Subviews and post-render actions.

    postRender() {
      this.tbody = this.$('.im-item-table tbody');
      if (!this.tbody.length) { throw new Error('Could not find table'); }
      this.addControls();
      return this.addItems();
    }

    addControls() {
      return this.renderChildAt('.im-summary-controls', (new SummaryItemsControls({model: this.model})));
    }

    addItems(from) { if (from == null) { from = 0; } if (this.rendered && (from < this.model.items.length)) {
      const next = from + 100;
      return _.defer(() => {
        const frag = document.createDocumentFragment();
        this.model.items.slice(from, next).forEach(item => this.addItem(item, frag));
        this.tbody.append(frag);
        return this.addItems(next);
      });
    } }

    addItem(model, body) { if (this.rendered) { // Wait until rendered.
      return this.renderChild((rowId(model)), (new FacetRow({model})), (body != null ? body : this.tbody));
    } }

    removeItem(model) { return this.removeChild(rowId(model)); }

    // Event definitions and their handlers

    events() {
      return {
        'click .im-load-more': 'loadMoreItems',
        'click .im-clear-value-filter': 'clearValueFilter',
        'keyup .im-filter-values': (_.throttle(this.filterItems, 250, {leading: false})),
        'submit': IGNORE, // not a real form - do not submit.
        'click': IGNORE // trap bubbled events.
      };
    }

    loadMoreItems() {
      if (this.model.get('loading')) { return; }
      return this.model.increaseLimit(2);
    }

    clearValueFilter() {
      const $input = this.$('.im-filter-values');
      $input.val(null);
      return this.model.setFilterTerm(null);
    }

    filterItems(e) { // Bound method because it is throttled in events.
      const $input = this.$('.im-filter-values');
      const val = $input.val();
      return this.model.setFilterTerm($input.val());
    }
  };
  SummaryItems.initClass();
  return SummaryItems;
})());

