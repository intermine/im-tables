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
