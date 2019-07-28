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
