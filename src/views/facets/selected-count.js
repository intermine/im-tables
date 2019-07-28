// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SelectedCount;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

require('../../messages/summary');

const sum = function(lens, xs) {
  if (lens == null) { lens = _.identity; }
  return _.reduce(xs, ((total, x) => total + lens(x)), 0);
};

// Sum up the .count properties of the things in an array.
const sumCounts = _.partial(sum, x => x.count);

// Sum up a list of partially overlapping buckets.
const sumPartials = (min, max, partials) => sum((_.partial(getPartialCount, min, max)), partials);

// Get the amount of of a given range a particular span overlaps.
// eg: ({min: 0, max: 10}, 0, 10) -> 1
// eg: ({min: 0, max: 10}, 20, 21) -> 0
// eg: ({min: 0, max: 10}, 0, 7) -> 0.7
// eg: ({min: 0, max: 10}, 5, 7) -> 0.2
const fracWithinRange = function(range, min, max) {
  if (!range) { return 0; }
  const rangeSize = range.max - range.min;
  const overlap = range.min < min ?
    Math.min(range.max, max) - min
  :
    max - Math.max(range.min, min);
  return overlap / rangeSize;
};

// get a filter to find buckets fully contained in a given range.
const fullyContained = (min, max) => b => (b.min >= min) && (b.max <= max);
// get a filter to find buckets partially overlapping a range to its left or right
const partiallyOverlapping = (min, max) => b => ((b.min < min) && (b.max > min)) || ((b.max > max) && (b.min < max)) ;

// Given a particular span, and a bucket, return an estimate of the number
// of values within the span, assuming that the bucket is evenly populated
// based on the size of the bucket and the amount of overlap.
var getPartialCount = (min, max, b) => b.count * fracWithinRange(b, min, max);

module.exports = (SelectedCount = (function() {
  SelectedCount = class SelectedCount extends CoreView {
    static initClass() {
  
      this.prototype.className = 'im-summary-selected-count';
  
      this.prototype.template = Templates.template('summary-selected-count');
    }

    stateEvents() {
      return {'change:selectedCount change:isApprox': this.reRender};
    }

    initialize({range}) {
      this.range = range;
      super.initialize(...arguments);
      this.listenTo(this.model.items, 'change:selected', this.estimateSelectionSize);
      return this.listenTo(this.range, 'change', this.estimateSelectionSize);
    }

    estimateSelectionSize() {
      if (!this.model.get('initialized')) { return; }
      if (this.model.get('numeric')) {
        return this.estimateSelectedInRange();
      } else {
        return this.sumSelectedItems();
      }
    }

    preRender() {
      if (!this.rendered) { return this.$el.hide(); }
      if (!this.state.get('selectedCount')) {
        return this.$el.slideUp();
      }
    }

    postRender() { if (this.state.get('selectedCount')) {
      return this.$el.slideDown();
    } }

    sumSelectedItems() {
      const selected = this.model.items.where({selected: true});
      const count = sum((i => i.get('count')), selected);
      return this.state.set({isApprox: false, selectedCount: count});
    }

    estimateSelectedInRange() {
      if (this.range.isAll()) { return this.state.unset('selectedCount'); }
      const {min, max} = this.range.toJSON();
      const histogram = this.getHistogram();
      const fullBuckets = histogram.filter(fullyContained(min, max));
      const partials = histogram.filter(partiallyOverlapping(min, max));
      const count = Math.round((sumCounts(fullBuckets)) + (sumPartials(min, max, partials)));
      return this.state.set({isApprox: true, selectedCount: count});
    }

    getHistogram() {
      const buckets = this.model.getHistogram();
      const maxVal = this.model.get('max');
      const minVal = this.model.get('min');
      const step = (maxVal - minVal) / buckets.length;
      return Array.from(buckets).map((c, i) => (
        {count: c, min: (minVal + (i * step)), max: (minVal + step + (i * step))}));
    }
  };
  SelectedCount.initClass();
  return SelectedCount;
})());

