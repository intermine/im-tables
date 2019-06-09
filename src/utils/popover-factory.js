// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Wrapper that caches the results of findById and count
// it fulfils the contract of ServiceType from item-preview
// This is not for general use, as it *only* returns promises,
// and ignores all callbacks.
//
// When Proxies come into general use, this would be an excellent
// use case for them.
let PopoverFactory;
class PreviewCachingService {

  constructor(wrapped) {
    this.wrapped = wrapped;
    this.root = this.wrapped.root;
    this._foundById = {};
    this._counts = {};
  }

  fetchModel() { return this.wrapped.fetchModel(); }

  findById(type, id, flds) {
    return this._foundById[`${ type }:${ id }:${ flds }`] != null ? this._foundById[`${ type }:${ id }:${ flds }`] : (this._foundById[`${ type }:${ id }:${ flds }`] = this.wrapped.findById(type, id, flds));
  }

  count(query) {
    let name;
    return this._counts[name = JSON.stringify(query)] != null ? this._counts[name] : (this._counts[name] = this.wrapped.count(query));
  }

  destroy() {
    this._foundById = {};
    this._counts = {};
    return delete this.wrapped;
  }
}

// Factory that wraps the service in a thick layer of sweet
// caching logic.
//
// The purpose of this is to minimise the performance penalty
// of having multiple cells representing the same entity on
// the same table - this way they share data requested through
// the service.
module.exports = (PopoverFactory = class PopoverFactory {

  constructor(service, Preview) {
    this.Preview = Preview;
    this.service = new PreviewCachingService(service);
  }

  // IMObject -> jQuery
  get(obj) {
    const {Preview, service} = this;
    const types = obj.get('classes'); // It would be nice to align these - TODO!
    const id = obj.get('id');

    return new Preview({service, model: {types, id}});
  }

  // Remove all popovers.
  destroy() {
    this.service.destroy();
    return delete this.service;
  }
});
