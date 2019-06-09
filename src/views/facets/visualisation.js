/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FacetVisualisation;
const Options = require('../../options');
const CoreView = require('../../core-view');

const NumericDistribution = require('./numeric');
const PieChart = require('./pie');
const Histogram = require('./histogram');
const SummaryItems = require('./summary-items');

// This child view is essentially a big if statement and dispatcher around
// column summary data.
module.exports = (FacetVisualisation = (function() {
  FacetVisualisation = class FacetVisualisation extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-facet-vis';
  
      this.prototype.RERENDER_EVENT = 'change:loading change:numeric change:canHaveMultipleValues';
    }

    initialize({range}) { this.range = range; return super.initialize(...arguments); }

    // Only show data when there is something to show.
    postRender() { if (this.model.get('initialized')) {
      return this.renderChild('vis', this.getVisualization());
    } }

    // Get the correct implementation to delegate to.
    getVisualization(args) {
      const {uniqueValues, numeric, canHaveMultipleValues, type, got} = this.model.toJSON();
      switch (false) {
        case !numeric: return new NumericDistribution({model: this.model, range: this.range});
        case uniqueValues !== 1: return null; // nothing to show
        case !canHaveMultipleValues: return new Histogram({model: this.model});
        case !(0 < uniqueValues && uniqueValues <= (Options.get('MAX_PIE_SLICES'))): return new PieChart({model: this.model});
        case !got: return new Histogram({model: this.model});
        default: return null;
      }
    }
  };
  FacetVisualisation.initClass();
  return FacetVisualisation; // no chart to show.
})());

