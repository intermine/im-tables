/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SummaryModel;
const _ = require('underscore');

const CoreModel = require('../core-model');
const Collection = require('../core/collection');
const Options = require('../options');

const {getColumnSummary} = require('../services/column-summary');

const inty = type => ['int', 'Integer', 'long', 'Long', 'short', 'Short'].includes(type);

// Represents the result of a column summary, and the options that affect it.
// Properties:
//  - filterTerm :: string
//  - maxCount :: int
//  - loading :: bool
//  - initialized :: bool
//  - got :: int
//  - available :: int
//  - filteredCount :: int
//  - uniqueValues :: int
//  - max, min, average, stdev (if numeric) :: floats
//  - numeric :: bool
//  - canHaveMultipleValues :: bool
//  - type :: string (as per PathInfo::getType)
//  - buckets :: int (The number of buckets in the histogram)
module.exports = (SummaryModel = class SummaryModel extends CoreModel {

  defaults() {
    return {
      error: null,
      maxCount: null,
      loading: false,
      initialized: false,
      canHaveMultipleValues: false,
      numeric: false,
      filterTerm: null
    };
  }

  constructor({query, view}) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { return this; }).toString();
      let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
      eval(`${thisName} = this;`);
    }
    this.query = query;
    this.view = view;
    super();
    if (this.query == null) { throw new Error('No query in call to new SummaryModel'); }
    if (this.view == null) { throw new Error('No view in call to new SummaryModel'); }
    this.fetch = _.partial(getColumnSummary, this.query, this.view);
    const type = this.view.getType();
    const integral = inty(type);
    this.set({ // Initial state - canHaveMultipleValues and type are not expected to change.
      limit: Options.get('INITIAL_SUMMARY_ROWS'),
      canHaveMultipleValues: this.query.canHaveMultipleValues(this.view),
      type,
      integral
    });
    this.histogram = new SummaryHistogram(); // numeric distribution by buckets.
    this.items = new SummaryItems();         // Most common items, most frequent first.
    this.listenTo(this, 'change:filterTerm', this.onFilterChange);
    this.listenTo(this, 'change:summaryLimit', this.onLimitChange);
    this.listenTo(this.query, 'change:constraints', this.load);
    this.load();
  }

  destroy() {
    this.histogram.close();
    this.items.close();
    return super.destroy(...arguments);
  }

  // The max count is set if the data is initialized.
  getMaxCount() { return this.get('maxCount'); }

  hasMore() { return (!this.get('numeric')) && (this.get('got') < this.get('uniqueValues')); }

  hasAll() { return !this.hasMore(); }

  // Include the items in the JSON output.
  toJSON() { return _.extend(super.toJSON(...arguments), {items: this.items.toJSON(), histogram: this.getHistogram()}); }

  onFilterChange() {
    if (this.hasAll()) {
      return this.filterLocally();
    } else {
      return this.load();
    }
  }

  // Applies the filter to the current set of items, setting 'visible' accordingly
  filterLocally() {
    const current = this.get('filterTerm');
    if (current != null) {
      const parts = current.toLowerCase().split(/\s+/);
      const test = str => _.all(parts, part => !!(str && ~str.toLowerCase().indexOf(part)));
      return this.items.each(x => x.show(test(x.get('item'))));
    } else {
      return this.items.each(x => x.show());
    }
  }

  increaseLimit(factor) {
    if (factor == null) { factor = 2; }
    const limit = factor * this.get('limit');
    return this.set({limit});
  }

  onLimitChange() { return this.load(); }

  setFilterTerm(filterTerm) { return this.set({filterTerm}); }

  fetchAll() { return this.set({limit: null}); }

  load() {
    this.set({loading: true});
    return this.fetch((this.get('filterTerm')), (this.get('limit')))
      .then(this.getSummaryHandler())
      .then(null, error => this.set({error}));
  }

  getSummaryHandler() {
    let created;
    this.lastSummaryHandlerCreatedAt = (created = _.now());
    return summary => this.handleSummary(created, summary);
  }

  getHistogram() { // histogram can be sparse, hence this method.
    let left;
    const n = this.get('buckets');
    if (!n) { return []; }
    return __range__(1, n, true).map((i) => // fill in empty buckets.
      (left = __guard__(this.histogram.get(i), x => x.get('count'))) != null ? left : 0);
  }

  handleSummary(time, {stats, results}) {
    // abort if results returned out-of-order, and we are not the most recent.
    let count, id, item;
    if (time !== this.lastSummaryHandlerCreatedAt) { return; }
    // stats has the following properties:
    //  - filteredCount, uniqueValues
    //  if numeric it also has:
    //  - min, max, average, stdev
    // results is an array, listing the items.
    const numeric = (stats.max != null);
    const newStats = {
      filteredCount: stats.filteredCount,
      uniqueValues: stats.uniqueValues,
      available: (stats.filteredCount != null ? stats.filteredCount : stats.uniqueValues), // the most specific of these two
      got: results.length,
      numeric,
      initialized: true,
      loading: false
    };
    if (numeric) { // - extract the numeric summary values.
      const {buckets, max, min, stdev, average} = stats;
      _.extend(newStats, {buckets, max, min, stdev: parseFloat(stdev), average: parseFloat(average)});
      if (this.items.size()) { // very strange - this summary has changed from items to numeric.
        this.items.reset(); // so there are no items, just stats and buckets
      }
      // Set performs a smart update, with the correct add, remove and change events.
      this.histogram.set((() => {
        let bucket;
        const result = [];
        for ({bucket, count} of Array.from(results)) {           result.push({item: bucket, count, id: bucket});
        }
        return result;
      })());
      newStats.maxCount = this.histogram.getMaxCount(); // not more than 20, ok to iterate.
    } else { // this is a frequency based summary
      if (this.histogram.size()) { // very strange - this summary has changed from numeric to items
        this.histogram.reset(); // so there is no histogram.
      }
      // Set performs a smart update, with the correct add, remove and change events.
      this.items.set((() => {
        const result1 = [];
        for (id = 0; id < results.length; id++) {
          ({item, count} = results[id]);
          result1.push({item, count, id});
        }
        return result1;
      })());
      newStats.maxCount = this.items.getMaxCount();
    }
    return this.set(newStats); // triggers all change events - but the collection is already consistent.
  }
});

class SummaryItemModel extends CoreModel {

  // This just lays out the expected properties for this model.
  defaults() {
    return {
      symbol: null,
      share: null,
      visible: true,
      selected: false,
      hover: false,
      count: 0,
      item: null
    };
  }

  // Declarative setters for the boolean attributes.

  select() { return this.set({selected: false}); }

  deselect() { return this.set({selected: false}); }

  // Unconditionally hide this model.
  hide() { return this.set({visible: false}); }

  // can be used to show unconditionally: model.show()
  // or it can be used to show if a condition is met: model.show ifCondition
  show(ifCondition) { if (ifCondition == null) { ifCondition = true; } return this.set({visible: ifCondition}); }

  mousein() { return this.set({hover: true}); }

  mouseout() { return this.set({hover: false}); }
}

// This is a collection of SummaryItemModels
class SummaryItems extends Collection {
  static initClass() {
  
    this.prototype.model = SummaryItemModel;
  }

  getMaxCount() { return __guard__(this.first(), x => x.get('count')); }
}
SummaryItems.initClass();

// This is a collection of SummaryItemModels
class SummaryHistogram extends Collection {
  static initClass() {
  
    this.prototype.model = SummaryItemModel;
  }

  getMaxCount() { return _.max(Array.from(this.models).map((b) => b.get('count'))); }
}
SummaryHistogram.initClass();

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}
function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}