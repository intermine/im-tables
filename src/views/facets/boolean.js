// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let BooleanChart;
const PieChart = require('./pie');

// The only difference between this class and a regular pie chart is the fact that
// boolean paths do not support multiple selection, which is enforced here.
module.exports = (BooleanChart = class BooleanChart extends PieChart {

  initialize() {
    super.initialize(...arguments);
    return this.listenTo(this.model.items, 'change:selected', this.deselectOthers);
  }
    
  // Only one value can be selected at a time (unlike pie charts and histograms,
  // which model multi-selection), so if something gets selected go through all the
  // other items and deselect them.
  deselectOthers(x, selected) { if (selected) {
    return this.model.items.each(function(m) { if (x !== m) { return m.deselect(); } });
  } }
});

