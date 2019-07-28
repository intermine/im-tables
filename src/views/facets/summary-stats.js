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
let SummaryStats;
const _ = require('underscore');

const CoreView = require('../../core-view');
const Templates = require('../../templates');

const DOWN = 40;
const UP = 38;
const NULL_STATS = {
  min: 0,
  max: 0,
  average: 0,
  stdev: 0
};

module.exports = (SummaryStats = (function() {
  SummaryStats = class SummaryStats extends CoreView {
    static initClass() {
  
      this.prototype.RERENDER_EVENT = 'change';
  
      this.prototype.className = 'im-summary-stats';
  
      this.prototype.template = Templates.template('summary_stats');
    }

    // Ensure the template has the required values.
    getData() { return _.extend({}, NULL_STATS, super.getData(...arguments)); }

    initialize({range}) {
      this.range = range;
      super.initialize(...arguments);
      this.listenTo(this.range, 'change', this.setSliderValues);
      this.listenTo(this.range, 'change', this.setButtonDisabledness);
      this.listenTo(this.range, 'change:min', this.onChangeMin);
      this.listenTo(this.range, 'change:max', this.onChangeMax);
      this.listenForChange(this.model, this.initType, 'integral', 'min', 'max');
      return this.initType();
    }

    invariants() {
      return {hasRange: "No range"};
    }

    hasRange() { return (this.range != null); }

    setSliderValues() {
      const {min, max} = this.range.toJSON();
      return (this.$slider != null ? this.$slider.slider('option', 'values', [min, max]) : undefined);
    }

    // Max sure the text input reflects the state of the slider, and vice-versa
    onChangeMin() {
      const min = this.range.get('min');
      this.$('input.im-range-min').val(min);
      if ((this.$slider != null) && (this.$slider.slider('values', 0) !== min)) {
        return this.$slider.slider('values', 0, min);
      }
    }

    // Max sure the text input reflects the state of the slider, and vice-versa
    onChangeMax() {
      const max = this.range.get('max');
      this.$('input.im-range-max').val(max);
      if ((this.$slider != null) && (this.$slider.slider('values', 1) !== max)) {
        return this.$slider.slider('values', 1, max);
      }
    }

    setButtonDisabledness() {
      const changed = this.range.isNotAll();
      return this.$('.btn').toggleClass('disabled', (!changed));
    }

    events() {
      return {
        'click'(e) { return e.stopPropagation(); },
        'keyup input.im-range-min': 'maybeIncrementMin',
        'keyup input.im-range-max': 'maybeIncrementMax',
        'change input.im-range-min': 'setRangeMin',
        'change input.im-range-max': 'setRangeMax',
        'click .btn-primary': 'changeConstraints',
        'click .btn-cancel': 'clearRange'
      };
    }

    clearRange() { return this.range.set(this.model.pick('min', 'max')); }

    maybeIncrementMin(e) { return this.maybeIncrement('min', e); }

    maybeIncrementMax(e) { return this.maybeIncrement('max', e); }

    maybeIncrement(prop, e) {
      let value = this.range.get(prop);
      switch (e.keyCode) {
        case DOWN: value -= this.step; break;
        case UP: value += this.step; break;
      }

      return this.range.set(prop, value);
    }

    setRangeMin() {
      return this.range.set({min: this.parse(this.$('.im-range-min').val())});
    }

    setRangeMax() {
      return this.range.set({max: this.parse(this.$('.im-range-max').val())});
    }

    changeConstraints(e) {
      e.preventDefault();
      e.stopPropagation();

      const path = this.model.view.toString();
      const { query } = this.model;
      const existingConstraints =  _.where(query.constraints, {path});

      const newConstraints = this.range.nulled ?
        [{path, op: 'IS NULL'}]
      :
        [
          {
            path,
            op: ">=",
            value: this.range.get('min')
          },
          {
            path,
            op: "<=",
            value: this.range.get('max')
          }
        ];

      // remove silently, since we will be triggering the change next.
      for (let c of Array.from(existingConstraints)) {
        query.removeConstraint(c, {silent: true});
      }

      return query.addConstraints(newConstraints);
    }

    postRender() { return this.drawSlider(); }

    parse(str) {
      try {
        if (this.step === 1) { return parseInt(str, 10); } else { return parseFloat(str); }
      } catch (e) {
        this.model.set({error: new Error(`Could not parse '${ str }' as a number`)});
        return null;
      }
    }

    initType() { // sets step and the rounding function.
      // For intish columns the step is 1, otherwise it is 1% of the range.
      const {integral, min, max} = this.model.toJSON();
      this.step = integral ? 1 : Math.abs((max - min) / 100);
      return this.round = integral ? Math.round : _.identity;
    }

    drawSlider() {
      const {max, min} = this.model.pick('min', 'max');
      return this.activateSlider({
        range: true,
        min,
        max,
        values: [min, max],
        step: this.step,
        slide: (e, ui) => (this.range != null ? this.range.set({min: ui.values[0], max: ui.values[1]}) : undefined)});
    }

    reRender() {
      this.destroySlider();
      return super.reRender(...arguments);
    }

    activateSlider(opts) {
      this.destroySlider(); // remove previous slider if present.
      this.$slider = this.$('.slider');
      return this.$slider.slider(opts);
    }

    destroySlider() { if (this.$slider != null) {
      this.$slider.slider('destroy');
      return this.$slider = null;
    } }

    remove() {
      this.destroySlider();
      return super.remove(...arguments);
    }
  };
  SummaryStats.initClass();
  return SummaryStats;
})());

