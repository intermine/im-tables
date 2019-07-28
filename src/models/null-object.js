let NullObject;
const CoreModel = require('../core-model');

module.exports = (NullObject = class NullObject extends CoreModel {

  constructor(type, field) {
    super();
    this.set({
      'id': null,
      'isNULL': true,
      'classes': [type],
      'service:base': '',
      'service:url': '',
      'report:uri': null
    });
    if (field) { this.set(field, null); }
  }
});

