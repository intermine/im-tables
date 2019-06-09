/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let NestedModel;
const _ = require('underscore');

const Model = require('../core-model');

const mergeOldAndNew = (oldValue, newValue) => _.extend({}, (_.isObject(oldValue) ? oldValue : {}), newValue);

const setSection = function(m, k) {
  const v = m[k];
  if (!_.isObject(v)) { // mid-sections must be indexable objects (including arrays)
    return m[k] = {};
  } else {
    return v;
  }
};

const isPlainObject = value => (_.isObject(value)) && (!_.isFunction(value)) && (!_.isArray(value));

// A version of Model that supports nested keys.
module.exports = (NestedModel = class NestedModel extends Model {

  _triggerChangeRecursively(ns, obj) {
    return (() => {
      const result = [];
      for (let k in obj) {
        const v = obj[k];
        const thisKey = `${ ns }.${ k }`;
        if (_.isObject(v)) {
          result.push(this._triggerChangeRecursively(thisKey, v));
        } else {
          result.push(this.trigger(`change:${ thisKey }`, this, this.get(thisKey)));
        }
      }
      return result;
    })();
  }

  get(key) { // Support nested keys
    if (_.isArray(key)) {
      const [head, ...tail] = Array.from(key);
      // Safely get properties.
      return tail.reduce(((m, k) => m && m[k]), super.get(head));
    } else if (/\w+\.\w+/.test(key)) {
      return this.get(key.split(/\./));
    } else {
      return super.get(key);
    }
  }

  pick(...attrs) { return _.object(_.flatten(attrs).map(a => [a, this.get(a)])); }

  // Trigger a change event for every segment.
  // eg: changing a.b.c will trigger the following events:
  //  * change
  //  * change:a
  //  * change:a.b
  //  * change:a.b.c
  // In that order.
  _triggerPathChange(key, value) {
    const path = [];
    this.trigger("change", this, key.join('.'), value);
    return (() => {
      const result = [];
      for (let section of Array.from(key)) {
        path.push(section);
        result.push(this.trigger(`change:${ path.join('.') }`, this, this.get(path)));
      }
      return result;
    })();
  }

  _triggerUnsetPath(path, prev) {
    if (_.isObject(prev)) {
      return (() => {
        const result = [];
        for (let k in prev) {
          const v = prev[k];
          result.push(this._triggerUnsetPath(path.concat([k]), v));
        }
        return result;
      })();
    } else {
      return this.trigger(`change:${ path.join('.') }`);
    }
  }

  // See tests for specification.
  set(key, value) { // Support nested keys
    let k, v;
    if (key == null) { throw new Error("No key"); }
    if (_.isArray(key)) { // Handle key paths.
      // Recurse into subkeys.
      if (isPlainObject(value)) {
        for (k in value) {
          v = value[k];
          this.set(key.concat([k]), v);
        }
        return;
      }

      const head = key[0],
        adjustedLength = Math.max(key.length, 2),
        mid = key.slice(1, adjustedLength - 1),
        end = key[adjustedLength - 1];
      const headVal = this.get(head);
      // Ensure the root is an object, unsetting it if it is a primitive or function.
      if (headVal && (_.isFunction(headVal) || (!_.isObject(headVal)))) {
        this.unset(head);
      }
      // Merge or create new path to value
      const root = (headVal != null ? headVal : {});
      const currentValue = mid.reduce(setSection, root);
      const prev = currentValue[end];
      currentValue[end] = value;
      super.set(head, root);
      this._triggerPathChange(key, value);
      if ((prev != null) && (value == null)) {
        return this._triggerUnsetPath(key, prev);
      }
    } else if (_.isString(key)) { // Handle calls as (String, Object) ->
      if (/\w+\.\w+/.test(key)) {
        return this.set((key.split(/\./)), value);
      } else if (_.isObject(value) && !_.isArray(value)) {
        return this.set([key], value);
      } else {
        return super.set(...arguments); // Handle simple key-value pairs, including unset.
      }
    } else { // Handle calls as (Object) ->, but ignore the options object.
      return (() => {
        const result = [];
        for (k in key) {
          v = key[k];
          result.push(this.set(k, v));
        }
        return result;
      })();
    }
  }
});

