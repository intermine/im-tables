/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let NumericRange;
const _ = require('underscore');
const Backbone = require('backbone');

// Not at all sure if this class is necessary, or at least if the way
// it manages its defaults isn't a little silly. On the other hand, it
// works, so there is that.
module.exports = (NumericRange = (function() {
  NumericRange = class NumericRange extends Backbone.Model {
    static initClass() {
  
      this.prototype._defaults = {};
    }

    setLimits(limits) { return _.extend(this._defaults, limits); }

    get(prop) {
      const ret = super.get(prop);
      if (ret != null) {
        return ret;
      } else if (prop in this._defaults) {
        return this._defaults[prop];
      } else {
        return null;
      }
    }

    toJSON() { return _.extend({}, this._defaults, this.attributes); }

    nullify() {
      this.unset('min');
      this.unset('max');
      this.nulled = true;
      return ['change:min', 'change:max', 'change'].map((evt) => this.trigger(evt, this));
    }

    reset() {
      this.clear();
      return this.trigger('reset', this);
    }

    set(name, value) {
      this.nulled = false;
      if (_.isString(name) && (name in this._defaults)) {
        const meth = name === 'min' ? 'max' : 'min';
        return super.set(name, Math[meth](this._defaults[name], value));
      } else {
        return super.set(...arguments);
      }
    }

    isAll() { return !this.isNotAll(); }

    isNotAll() {
      if (this.nulled) { return false; }
      const {min, max} = this.toJSON();
      return ((min != null) && (min !== this._defaults.min)) || ((max != null) && (max !== this._defaults.max));
    }
  };
  NumericRange.initClass();
  return NumericRange;
})());

