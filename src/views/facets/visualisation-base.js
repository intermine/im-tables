// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let VisualisationBase;
const d3 = require('d3-browserify');
const _ = require('underscore');

const CoreView = require('../../core-view');

module.exports = (VisualisationBase = (function() {
  VisualisationBase = class VisualisationBase extends CoreView {
    static initClass() {
  
      this.prototype.chartHeight = 0; // the height of the chart - should be a number
      this.prototype.chartWidth = 0;
       // the width we have available - set during render.
    }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this.model, 'change:loading', this.reRender);
    }

    postRender() {
      if (this.model.get('loading')) { return; }
      return this.addChart();
    }

    addChart() { return _.defer(() => {
      try {
        return this._drawD3Chart();
      } catch (e) {
        return this.model.set({error: e});
      }
    }); }

    // These methods need implementing by sub-classes - standard ABC stuff here.
    getScales() { throw new Error('Not implemented'); }

    selectNodes(chart) { throw new Error('not implemented'); }

    getChartData(scales) { throw new Error('not implemented'); }

    exit(selection) { return selection.remove(); }

    enter(selection, scales) { throw new Error('not implemented'); }

    update(selection, scales) { throw new Error('not implemented'); }

    // If you want axes, then implement this method.
    drawAxes(chart, scales) {} // optional.

    // Return true to abort drawing the chart.
    shouldNotDrawChart() { return false; }

    _drawD3Chart() {
      if (this.shouldNotDrawChart()) { return; }
      this.initChart();
      const scales = this.getScales();
      const chart = this.getCanvas();

      this.updateChart(chart, scales);

      return this.drawAxes(chart, scales);
    }

    // Call this method when the data changes to update the visualisation.
    updateChart(chart, scales) {
      if (this.shouldNotDrawChart()) { return; }
      if (chart == null) { chart = this.getCanvas(); } // when updating
      if (scales == null) { scales = this.getScales(); } // when updating

      // Bind each data item to a node in the chart.
      const selection = this.selectNodes(chart).data(this.getChartData(scales));

      // Remove any unneeded nodes
      this.exit(selection.exit());

      // Initialise any new nodes
      this.enter(selection.enter(), scales);

      // Transition the nodes to their new state.
      return this.update(selection, scales);
    }

    // Set properties that we need access to the DOM to calculate.
    initChart() {
      return this.chartWidth = this.$el.closest(':visible').width();
    }

    // Get the canvas if it exists, or create it.
    getCanvas() {
      return this.paper != null ? this.paper : (this.paper = d3.select(this.el)
                  .append('svg')
                    .attr('class', 'im-summary-chart')
                    .attr('width', this.chartWidth)
                    .attr('height', this.chartHeight));
    }
  };
  VisualisationBase.initClass();
  return VisualisationBase;
})());
