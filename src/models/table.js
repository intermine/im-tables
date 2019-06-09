/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let TableModel;
const Options = require('../options');
const CoreModel = require('../core-model');
const PathSet = require('./path-set');

module.exports = (TableModel = class TableModel extends CoreModel {

  constructor(...args) {
    {
      // Hack: trick Babel/TypeScript into allowing this before super.
      if (false) { super(); }
      let thisFn = (() => { return this; }).toString();
      let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
      eval(`${thisName} = this;`);
    }
    this.filled = this.filled.bind(this);
    super(...args);
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

