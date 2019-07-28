// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS204: Change includes calls to have a more natural evaluation order
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let NumericDistribution;
const d3 = require('d3-browserify');
const $ = require('jquery');
const _ = require('underscore');

const Options = require('../../options');
const Messages = require('../../messages');
require('../../messages/summary'); // include the summary messages.
const VisualisationBase = require('./visualisation-base');

const NULL_SELECTION_WIDTH = 25;

// Helper that constructs a scale fn from the given input domain to the given output range
const scale = (input, output) => d3.scale.linear().domain(input).range(output);

// A function that takes the number of a bucket and a function that will turn that into
// a value in the continous range of values for the paths and produces an object saying
// what the range of values are for the bucket.
// (Function<int, Number>, int) -> {min :: Number, max :: Number}
const bucketRange = function(bucketVal, bucket) {
  const [min, max] = Array.from(([0, 1].map((delta) => bucketVal(bucket + delta))));
  return {min, max};
};

// Function that enforces limits on a value.
const limited = (min, max) => function(x) {
  if (x < min) {
    return min;
  } else if (x > max) {
    return max;
  } else {
    return x;
  }
} ;

module.exports = (NumericDistribution = (function() {
  NumericDistribution = class NumericDistribution extends VisualisationBase {
    static initClass() {
  
      this.prototype.className = "im-numeric-distribution";
  
      // Dimensions of the chart.
      this.prototype.leftMargin = 25;
      this.prototype.bottomMargin = 18;
      this.prototype.rightMargin = 14;
      this.prototype.chartHeight = 70;
  
      // Flag so we know if we are selecting paths.
      this.prototype.__selecting_paths = false;
  
      // The rubber-band selection.
      this.prototype.selection = null;
    }

    // Range is shared by other components, so we accept it from the outside.
    // We listen to changes on the range and respond by drawing a selection box.
    initialize({range}) {
      this.range = range;
      super.initialize(...arguments);
      return this.listenTo(this.range, 'change reset', this.onChangeRange);
    }

    // Things to check when we are initialised.
    invariants() {
      return {
        hasRange: "No range",
        hasHistogramModel: `Wrong model: ${ this.model }`
      };
    }

    hasRange() { return (this.range != null); }

    hasHistogramModel() { return ((this.model != null ? this.model.getHistogram : undefined) != null); }

    // The rendering logic. This component renders a numeric histogram.
    // 
    // the histogram is a list of values, eg: [1, 3, 5, 0, 10, 7, 4],
    // these represent a set of equal width buckets across the range
    // of the available values. Buckets are 1-indexed (in the example
    // above there are 7 buckets, labelled 1-7). The number of buckets
    // is available on the SummaryItems model as 'buckets', the
    // histogram can be accessed with SummaryItems::getHistogram.

    // Each bucket is represented by a rect which is placed on the canvas.
    selectNodes(chart) { return chart.selectAll('rect'); }

    // For convenience we store the bucket number with the count, although it
    // is trivial to calculate from the index. The range is also stored, which
    // is more of a faff to calculate (since you need access to the scales)
    getChartData(scales) {
      if (scales == null) { scales = this.getScales(); }
      return Array.from(this.model.getHistogram()).map((c, i) => (
        {count: c, bucket: (i + 1), range: (bucketRange(scales.bucketToVal, i + 1))}));
    }

    // Set properties that we need access to the DOM to calculate.
    initChart() {
      super.initChart(...arguments);
      this.bucketWidth = (this.model.get('max') - this.model.get('min')) / this.model.get('buckets');
      return this.stepWidth = (this.chartWidth - (this.leftMargin + 1)) / this.model.get('buckets');
    }

    // There are five separate things here:
    //  - x positions (the graphical position horizontally)
    //  - y positions (the graphical position vertically)
    //  - values (the values the path can hold - a continous range)
    //  - buckets (the number of the equal width buckets a value falls into)
    //  - counts (the number of values in a bucket)
    // The x scale is BucketNumber -> XPos
    // The y scale is Count -> YPos
    // We also need reverse scales for finding value for an x-position.
    getScales() {
      let scales;
      const {min, max} = this.model.pick('min', 'max');
      const n = this.model.get('buckets');
      const histogram = this.model.getHistogram();
      const most = d3.max(histogram);

      // These are the five separate things.
      const counts = [0, most];
      const values = [min, max];
      const buckets = [1, n + 1];
      const xPositions = [this.leftMargin, this.chartWidth - this.rightMargin];
      const yPositions = [0, this.chartHeight - this.bottomMargin];

      // wrapper around a ->val scale that applies the appropriate rounding and limits
      const toVal = inputs => _.compose((limited(min, max)), (scale(inputs, values)));

      return scales = { // return:
        x: (scale(buckets, xPositions)), // A scale from bucket -> x
        y: (scale(counts, yPositions)),  // A scale from count -> y
        valToX: (scale(values, xPositions)), // A scale from value -> x
        xToVal: (toVal(xPositions)), // A scale from x -> value
        bucketToVal: (toVal(buckets)) // A scale from bucket -> min val
      };
    }

    // Does the path represent a whole number value, such as an integer?
    isIntish() { let needle;
    return (needle = this.model.get('type'), ['int', 'Integer', 'long', 'Long', 'short', 'Short'].includes(needle)); }

    // Return a function we can use to round values we calculate from x positions.
    getRounder() { if (this.isIntish()) { return Math.round; } else { return _.identity; } }

    // The things we do to new rectangles.
    enter(selection, scales) {
      // For performance it is best to pass this in, but this line makes it clear what scales
      // refers to.
      if (scales == null) { scales = this.getScales(); }
      const container = this.el;
      const round = this.getRounder();
      const h = this.chartHeight;

      // When the user clicks on a bar, set the selected range to the range
      // the bar covers.
      const barClickHandler = (d, i) => {
        if (d.count > 0) {
          return this.range.set(d.range);
        } else {
          return this.range.nullify();
        }
      };

      // Get the tooltip text for the bar.
      const getTitle = ({range: {min, max}, count}) => Messages.getText('summary.Bucket', {count, range: {min: (round(min)), max: (round(max))}});

      // The inital state of the bars is 0-height in the correct x position, with click
      // handlers and tooltips attached.
      return selection.append('rect')
               .attr('x', (d, i) => scales.x(d.bucket)) // - 0.5 # subtract half a bucket to be at start
               .attr('width', d => Math.max(0, (scales.x(d.bucket + 1)) - (scales.x(d.bucket))))
               .attr('y', h - this.bottomMargin) // set the height to 0 initially.
               .attr('height', 0)
               .classed('im-bucket', true)
               .classed('im-null-bucket', d => d.bucket === null) // I suspect this is pointless.
               .on('click', barClickHandler)
               .each(function(d) { return $(this).tooltip({container, title: getTitle(d)}); });
    }

    update(selection, scales) {
      if (scales == null) { scales = this.getScales(); }
      const h = this.chartHeight;
      const bm = this.bottomMargin;
      const {Duration, Easing} = Options.get('D3.Transition');
      const height = d => scales.y(d.count);
      return selection.transition()
               .duration(Duration)
               .ease(Easing)
               .attr('height', height)
               .attr('y', d => h - bm - (height(d)) - 0.5);
    }

    // Axes are drawn with tick-lines.
    drawAxes(chart, scales) {
      if (chart == null) { chart = this.getCanvas(); }
      if (scales == null) { scales = this.getScales(); }
      const bottom = this.chartHeight - this.bottomMargin - .5;
      const container = this.el;

      // Draw a line for the average, if we are meant to.
      if (Options.get('Facets.DrawAverageLine')) {
        chart.append('line')
            .classed('average', true)
            .attr('x1', scales.valToX(this.model.get('average')))
            .attr('x2', scales.valToX(this.model.get('average')))
            .attr('y1', 0)
            .attr('y2', bottom)
            .each(function() { return $(this).tooltip({container, title: Messages.getText('summary.Average')}); });
      }

      // Draw a line across the bottom of the chart.
      chart.append('line')
           .classed('axis', true)
           .attr('x1', 0)
           .attr('x2', this.chartWidth)
           .attr('y1', bottom)
           .attr('y2', bottom);

      const axis = chart.append('svg:g');

      const ticks = scales.x.ticks(this.model.get('buckets'));

      // Draw a tick line for each bucket.
      return axis.selectAll('line').data(ticks)
          .enter()
            .append('svg:line')
            .classed('tick-line', true)
            .attr('x1', scales.x)
            .attr('x2', scales.x)
            .attr('y1', this.chartHeight - (this.bottomMargin * 0.75))
            .attr('y2', this.chartHeight - this.bottomMargin);
    }

    // Events, with their definitions and handlers.
    // Also, each bar has a handler (see ::enter) and the range itself
    // has handlers (see ::initialize)
    events() {
      return {'mouseout': () => { return this.__selecting_paths = false; }}; // stop selecting when the mouse leaves the el.
    }

    // Draw the rubber-band selection over the top of the canvas. The selection
    // is a full height box starting at x and extending to the right for width pixels.
    drawSelection(x, width) {
      if (((x == null)) || (x <= 0) || (width >= this.chartWidth)) {
        return this.removeSelection();
      }
      
      // Create it if it doesn't exist.
      if (this.selection == null) { this.selection = this.getCanvas().append('svg:rect')
                                .attr('y', 0)
                                .attr('height', this.chartHeight * 0.9)
                                .classed('rubberband-selection', true); }
      // Change its width and x position.
      return this.selection.attr('x', x).attr('width', width);
    }

    // When the range changes, draw the selection box, if we need to.
    onChangeRange() {
      if (this.shouldDrawBox()) {
        const scales = this.getScales();
        const {min, max} = this.range.toJSON();
        const start = scales.valToX(min);
        const width = (scales.valToX(max)) - start;
        return this.drawSelection(start, width);
      } else {
        return this.removeSelection();
      }
    }

    removeSelection() {
      if (this.selection != null) {
        this.selection.remove();
      }
      return this.selection = null;
    }

    // We should draw the selection box when there is a selection.
    shouldDrawBox() { return this.range.isNotAll(); }

    remove() { // remove the chart if necessary.
      this.removeSelection();
      if (this.paper != null) {
        this.paper.remove();
      }
      return super.remove(...arguments);
    }
  };
  NumericDistribution.initClass();
  return NumericDistribution;
})());

