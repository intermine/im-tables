// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FacetView;
const Event = require('../../event');
const CoreView = require('../../core-view');
const Options = require('../../options');

// methods we are composing in.
const SetsPathNames = require('../../mixins/sets-path-names');

// The data-model object.
const SummaryItems = require('../../models/summary-items');
const NumericRange = require('../../models/numeric-range');

// The child views of this view.
const SummaryHeading = require('./summary-heading');
const FacetItems = require('./items');
const SelectedCount = require('./selected-count');
const FacetVisualisation = require('./visualisation');

module.exports = (FacetView = (function() {
  FacetView = class FacetView extends CoreView {
    constructor(...args) {
      super(...args);
      this.Model = this.Model.bind(this);
    }

    static initClass() {
  
      this.include(SetsPathNames);
  
      this.prototype.parameters = ['query', 'view'];
  
      this.prototype.optionalParameters = ['noTitle'];
    }

    className() { return 'im-facet-view'; }

    modelEvents() {
      return {'change:min change:max': this.setLimits};
    }

    stateEvents() {
      return {'change:open': this.honourOpenness};
    }

    Model() { return new SummaryItems({query: this.query, view: this.view}); }

    // May inherit state, defines a model based on @query and @view
    initialize() {
      super.initialize(...arguments);
      this.range = new NumericRange;
      this.setPathNames();
      return this.setLimits();
    }

    initState() {
      if (!this.state.has('open')) { return this.state.set({open: Options.get('Facets.Initally.Open')}); }
    }

    setLimits() { if (this.model.get('numeric')) {
      return this.range.setLimits(this.model.pick('min', 'max'));
    } }

    // Conditions that must be true by initialisation.

    invariants() {
      return {
        hasQuery: "No query",
        hasAttrView: `The view is not an attribute: ${ this.view }`,
        modelIsSummaryItemsModel: `The model is not a summary items model: ${ this.model }`
      };
    }

    modelIsSummaryItemsModel() { return this.model instanceof SummaryItems; }

    hasQuery() { return (this.query != null); }

    hasAttrView() { return __guardMethod__(this.view, 'isAttribute', o => o.isAttribute()); }

    // Rendering logic. This is a composed view that has no template of its own.

    postRender() {
      this.renderTitle();
      this.renderVisualisation();
      this.renderSelectedCount();
      this.renderItems();
      return this.honourOpenness();
    }

    renderTitle() {
      if (!this.noTitle) { return this.renderChild('title', (new SummaryHeading({model: this.model, state: this.state}))); }
    }

    renderVisualisation() {
      return this.renderChild('viz', (new FacetVisualisation({model: this.model, state: this.state, range: this.range})));
    }

    renderSelectedCount() {
      return this.renderChild('count', (new SelectedCount({model: this.model, range: this.range})));
    }

    renderItems() {
      return this.renderChild('facet', (new FacetItems({model: this.model, state: this.state, range: this.range})));
    }

    honourOpenness() {
      const isOpen = this.state.get('open');
      const wasOpen = this.state.previous('open');
      const facet = this.$('dd.im-facet');

      if (isOpen) {
        facet.slideDown();
        this.trigger('opened', this);
      } else {
        facet.slideUp();
        this.trigger('closed', this);
      }

      if ((wasOpen != null) && (isOpen !== wasOpen)) {
        return this.trigger('toggled', this);
      }
    }

    // Event definitions and their handlers.

    events() {
      return {'click .im-summary-heading': 'toggle'};
    }

    toggle() { return this.state.toggle('open'); }

    close() { return this.state.set({open: false}); }

    open() { return this.state.set({open: true}); }
  };
  FacetView.initClass();
  return FacetView;
})());


function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}