let StepModel;
const _ = require('underscore');
const CoreModel = require('../core-model');
const Executor = require('../utils/count-executor');

// A model that captures the state of a moment in the history.
// It maintains the count of the query through a caching executor,
// and records the time it was created.
module.exports = (StepModel = class StepModel extends CoreModel {

  defaults() {
    return {count: 0};
  }

  initialize() {
    super.initialize(...arguments);
    this.set({createdAt: (new Date())});
    this.listenTo(this, 'change:query', this._setCount);
    return this._setCount();
  }

  _setCount() {
    const q = this.get('query');
    if (q != null) {
      return Executor.count(q).then(c => this.set({count: c}));
    } else {
      return this.set({count: 0});
    }
  }

  toJSON() { return _.extend(super.toJSON(...arguments), {query: this.get('query').toJSON()}); }
});

