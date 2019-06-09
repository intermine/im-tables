// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let HistoFacet;
const d3 = require('d3-browserify');
const _ = require('underscore');

const Options = require('../../options');
const Messages = require('../../messages');
const VisualisationBase = require('./visualisation-base');

require('../../messages/summary'); // include the summary messages.

const {bool} = require('../../utils/casts');

// Helper that constructs a scale fn from the given input domain to the given output range
const scale = (input, output) => d3.scale.linear().domain(input).range(output);

module.exports = (HistoFacet = (function() {
  HistoFacet = class HistoFacet extends VisualisationBase {
    static initClass() {
  
      this.prototype.className = 'im-summary-histogram';
  
      this.prototype.chartHeight = 50;
      this.prototype.leftMargin = 25;
      this.prototype.rightMargin = 25;
      this.prototype.bottomMargin = 0.5;
      this.prototype.stepWidth = 0;
       // The width of each bar, in pixels - set during render.
    }

    allCountsAreOne() { return this.model.get('maxCount') === 1; }

    initialize() {
      super.initialize(...arguments);
      return this.listenTo(this.model.items, 'add remove change:selected', () => this.updateChart());
    }

    // Preconditions

    invariants() {
      return {'hasItems': `No items, or not the right thing: ${ this.model.items }`};
    }

    hasItems() { return (__guard__(this.model != null ? this.model.items : undefined, x => x.models) != null); } // It should look like a collection.

    // Set properties that we need access to the DOM to calculate.
    initChart() {
      super.initChart(...arguments);
      return this.stepWidth = (this.chartWidth - (this.leftMargin + this.rightMargin + 1)) / this.model.items.size();
    }

    shouldNotDrawChart() { return this.allCountsAreOne(); }

    // The rendering logic. This component renders a frequency histogram.

    // This component visualises one bar for each value, in a list, arrayed
    // along the x axis, with their height set to reflect their count.
    getScales() {
      // intentionally one off, so there is enough space for the last bar.
      const indices = [0, this.model.items.size()]; // the indices of the bars, i .. n
      const counts = [0, this.model.get('maxCount')]; // The range of counts, zeroed.
      const yPositions = [0, this.chartHeight - this.bottomMargin];
      const xPositions = [this.leftMargin, this.chartWidth - this.rightMargin];

      const x = (scale(indices, xPositions));
      const y = (scale(counts, yPositions));

      return {x, y};
    }

    // Each item is represented by a rectangle on the chart.
    selectNodes(chart) { return chart.selectAll('rect'); }

    // One bar is drawn for each item in the result set, which is the list
    // of possible values and the number of the occurances of each one, ordered
    // from most frequent to least frequent.
    getChartData(scales) { return this.model.items.models.slice(); }
  
    // One bar is drawn for each item.
    enter(selection, scales) {
      return selection.append('rect')
               .classed('im-item-bar', true)
               .classed('squashed', this.stepWidth < 4)
               .attr('width', this.stepWidth)
               .attr('y', this.chartHeight)  // Correct value set in transition
               .attr('height', 0)        // Correct value set in transition
               .attr('x', (_, i) => scales.x(i))
               .on('click', model => model.toggle('selected'))
               .on('mouseover', model => model.mousein())
               .on('mouseout', model => model.mouseout());
    }

    // Transition to the correct height and selected state.
    update(selection, scales) {
      const {Duration, Easing} = Options.get('D3.Transition');
      const h = this.chartHeight - this.bottomMargin;
      const height = model => scales.y(model.get('count'));
      selection.classed('selected', model => model.get('selected'));
      return selection.transition()
               .duration(Duration)
               .ease(Easing)
               .attr('height', height)
               .attr('y', model => h - (height(model)));
    }

    // Draw an X-axis.
    drawAxes(chart, scales) {
      const y = this.chartHeight - this.bottomMargin;
      return chart.append('line')
        .classed('x-axis', true)
        .attr('x1', 0)
        .attr('x2', this.chartWidth)
        .attr('y1', y)
        .attr('y2', y);
    }
  };
  HistoFacet.initClass();
  return HistoFacet;
})());
    

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}