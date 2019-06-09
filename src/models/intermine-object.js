// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let IMObject;
const _ = require('underscore');
const CoreModel = require('../core-model');

// The data fields are separated from meta-data
// by using colons in their field names, which are illegal data field name characters.
module.exports = (IMObject = class IMObject extends CoreModel {

  // @param base [String] the base URL
  // @param types [Array<PathInfo>] The type of this entity.
  // @param id [any] the (opaque) id of this entity.
  constructor(base, types, id) {
    super({classes: (types != null ? types.map(String) : undefined), id}); // set identifying values.
    this.set({'service:base': base});
    this.freeze('service:base', 'id', 'classes'); // Do not allow these properties to change.
  }

  toJSON() {
    const url = this.get('service:url');
    const uri = (/^http/.test(url)) ?
      url
    :
      this.get('service:base') + url;
    return _.extend(super.toJSON(...arguments), {'report:uri': uri});
  }

  merge(obj, field) {
    this.set(field, obj.value);
    return this.set({'service:url': obj.url});
  }
});

