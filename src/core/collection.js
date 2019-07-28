let CoreCollection;
const Backbone = require('backbone');
const CoreModel = require('../core-model');

// Clean up models on destruction.
module.exports = (CoreCollection = (function() {
  CoreCollection = class CoreCollection extends Backbone.Collection {
    static initClass() {
  
      this.prototype.model = CoreModel;
    }

    close() {
      let m;
      this.trigger('close', this);
      this.off(); // prevent trigger loops.
      while ((m = this.pop())) {
        if (m.collection === this) {
          delete m.collection;
          m.destroy();
        }
      }
      this.reset();
      return this.stopListening();
    }
  };
  CoreCollection.initClass();
  return CoreCollection;
})());
