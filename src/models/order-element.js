// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let OrderElementModel;
const PathModel = require('./path');

module.exports = (OrderElementModel = class OrderElementModel extends PathModel {

  constructor({path, direction}) {
    super(path);
    if (direction == null) { direction = 'ASC'; }
    this.set({direction});
  }

  asOrderElement() { return this.pick('path', 'direction'); }

  toOrderString() { return `${ this.get('path')} ${ this.get('direction') }`; }
});
