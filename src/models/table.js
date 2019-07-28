let TableModel;
const Options = require('../options');
const CoreModel = require('../core-model');
const PathSet = require('./path-set');

module.exports = (TableModel = class TableModel extends CoreModel {

  constructor(...args) {
    super(...args);
    this.filled = this.filled.bind(this);
  }

  defaults() {
    return {
      phase: 'FETCHING', // FETCHING, SUCCESS or ERROR
      start: 0,
      size: (Options.get('DefaultPageSize')),
      count: null,
      fill: 0, // counter of the number of times we have filled the rows
      error: null,
      selecting: false, // are we picking objects from the table?
      previewOwner: null, // Who owns the currently displayed preview?
      highlitNode: null, // Which node should we be highlighting?
      minimisedColumns: (new PathSet)
    };
  }

  initialize() {
    const minimisedColumns = this.get('minimisedColumns');
    this.listenTo(minimisedColumns, 'add remove reset', function() { return this.trigger('change:minimisedColumns change'); });
    return this.freeze('minimisedColumns');
  }

  filled() { return this.swap('fill', n => n + 1); }

  toJSON() {
    const data = super.toJSON(...arguments);
    data.minimisedColumns = this.get('minimisedColumns').toJSON().map(String);
    return data;
  }

  destroy() {
    this.get('minimisedColumns').close();
    return super.destroy(...arguments);
  }
});

