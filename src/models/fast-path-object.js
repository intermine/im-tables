// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
let FPObject;
const CoreModel = require('../core-model');

// FastPathObjects are light-weight data-base objects that
// don't have ids. Because of this we can't merge them or
// link to report pages or show previews.
module.exports = (FPObject = class FPObject extends CoreModel {

  constructor(obj, field) {
    super();
    this.set({
      'id': null,
      'classes': [obj.class],
      'service:base': '',
      'service:url': '',
      'report:uri': null
    });
    this.set(field, obj.value);
  }
});

