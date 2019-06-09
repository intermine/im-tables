// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let CoreModel;
const Backbone = require('backbone');

const invert = x => !x;

// Extension to Backbone.Model which adds some useful helpers
//  - @swap(key, (val) -> val) - replaces value with derived value
//  - @toggle(key) - Specialisation of swap for booleans.
module.exports = (CoreModel = (function() {
  CoreModel = class CoreModel extends Backbone.Model {
    static initClass() {
  
      this.prototype.destroyed = false;
  
      this.prototype._frozen = [];
    }

    // Helper to toggle the state of boolean value (using not)
    toggle(key) { return this.swap(key, invert); }

    // Helper to change the value of an entry using a function.
    swap(key, f) { return this.set(key, f(this.get(key))); }

    toJSON() { if (this.destroyed) { return 'DESTROYED'; } else { return super.toJSON(...arguments); } }

    // Release listeners in both directions, and delete
    // all instance properties.
    // Unlike in the standard backboniverse, this does not
    // attempt to sync with anywhere.
    destroy() { if (!this.destroyed) { // re-entrant.
      this.stopListening();
      this.destroyed = true;
      this.trigger('destroy', this, this.collection);
      this._frozen = [];
      this.clear();
      return this.off();
    } }

    _validate(attrs, opts) {
      for (let p of Array.from(this._frozen)) {
        if ((p in attrs) && (attrs[p] !== this.get(p))) {
          const msg = `${ p } is frozen (trying to set it to ${ attrs[p] } - is ${ this.get(p) })`;
          if (opts.merge) { // Expected when calling set. Rethink this if this causes bugs.
            // console.debug 'ignoring merge'
            attrs[p] = this.get(p); // otherwise it will be overwritten.
          } else {
            throw new Error(msg);
          }
        }
      }
      return super._validate(...arguments);
    }

    // Calls to set(prop) after freeze(prop) will throw.
    freeze(...properties) {
      this._frozen = this._frozen.concat(properties);
      return this;
    }
  };
  CoreModel.initClass();
  return CoreModel;
})());

