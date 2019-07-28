// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FacetItems;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

// Child views that we delegate to.
const SummaryStats = require('./summary-stats'); // when it is numeric.
const SummaryItems = require('./summary-items'); // when it is a list of items.
const OnlyOneItem = require('./only-one-item');  // when there is only one.
const NoResults = require('./no-results');       // when there is nothing

const REQ_ATTRS = ['error', 'initialized'];

// This class presents the items contained in the summary information, either
// as a list for frequencies, or showing statistics for numerical summaries.
// It is also responsible for showing an error message in case one needs to be shown,
// and a throbber while we are loading data.
//
// In this case we cannot just delegate directly to one of SummaryStats or SummaryItems,
// since we cannot predict until we have results whether a path will be summarised as
// a numerical distribution or as a count of items.
module.exports = (FacetItems = (function() {
  FacetItems = class FacetItems extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-facet-items';
  
      this.prototype.template = Templates.template('facet_frequency');
  
      // model values read by the template or which cause the subviews to need re-creation.
      this.prototype.RERENDER_EVENT = 'change:error change:numeric change:uniqueValues change:initialized';
    }

    // This model has a reference to the NumericRange model, so it can
    // be passed on the SummaryStats child if this path turns out to be numeric.
    initialize({range}) { this.range = range; return super.initialize(...arguments); }

    invariants() {
      return {modelHasRequiredAttrs: `Model only has the following attributes: ${ _.keys(this.model.attributes) }`};
    }

    modelHasRequiredAttrs() { return (_.intersection(REQ_ATTRS, _.keys(this.model.attributes))).length === 2; }

    modelEvents() { return {destroy: this.stopListening}; }

    // If data has been fetched, then display it.
    postRender() { if (this.model.get('initialized')) {
      return this.renderChild('items', this.getItems());
    } }

    // dispatch to one of the child view implementations.
    getItems() { switch (false) {
      case !this.model.get('numeric'):            return new SummaryStats({model: this.model, range: this.range});
      case !(this.model.get('uniqueValues') > 1):  return new SummaryItems({model: this.model});
      case this.model.get('uniqueValues') !== 1: return new OnlyOneItem({model: this.model, state: this.state});
      default: return new NoResults({model: this.state});
    } }
  };
  FacetItems.initClass();
  return FacetItems;
})());

