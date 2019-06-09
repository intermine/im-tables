/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');
const Backbone = require('backbone');

exports.ignore = function(e) {
  if (e != null) {
    e.preventDefault();
  }
  if (e != null) {
    e.stopPropagation();
  }
  return false;
};

const Cls = (exports.Bus = class Bus {
  static initClass() {
  
    _.extend(this.prototype, Backbone.Events);
  }

  destroy() {
    this.stopListening();
    return this.off();
  }
});
Cls.initClass();
