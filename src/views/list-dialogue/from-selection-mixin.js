/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const SelectedObjects = require('../../models/selected-objects');
const TypeAssertions = require('../../core/type-assertions');

const NO_COMMON_TYPE = {
  level: 'Error',
  key: 'lists.NoCommonType',
  cannotDismiss: true
};

const NO_OBJECTS_SELECTED = {
  level: 'Info',
  key: 'lists.NoObjectsSelected',
  cannotDismiss: true
};

module.exports = function(Base) {

  return {
    parameters: ['service', 'collection'], // collection must be SelectedObjects

    parameterTypes: {
      collection: (TypeAssertions.InstanceOf(SelectedObjects, 'SelectedObjects'))
    },

    className() { return Base.prototype.className.call(this) + ' im-list-picker'; },

    // :: -> Promise<Query>
    getQuery() { return this.service.query({
      from: this.model.get('type'),
      select: ['id'],
      where: [{path: this.model.get('type'), op: 'IN', ids: this.getIds()}]}); },
 
    // :: -> Promise<int>
    // The count is the number of ids, which we know statically.
    fetchCount() { return Promise.resolve(this.collection.size()); },

    // :: -> Table?
    getType() { if (this.model.get('type')) {
      return (this.schema != null ? this.schema.makePath(this.model.get('type')).getType() : undefined);
    } },

    // :: -> Service
    getService() { return this.service; },

    // Our private implementation.
    collectionEvents() {
      return {
        'change:commonType change:typeName': this.setType,
        'add remove': this.setCount
      };
    },

    initiallyMinimised: true,

    getIds() { return this.collection.map(o => o.get('id')); },

    onChangeType() {
      Base.prototype.onChangeType.call(this);
      return this.verifyState();
    },

    verifyState() {
      if (Base.prototype.verifyState != null) {
        Base.prototype.verifyState.call(this);
      }
      if (!this.collection.size()) {
        return this.state.set({error: NO_OBJECTS_SELECTED});
      } else if (!this.model.get('type')) {
        return this.state.set({error: NO_COMMON_TYPE});
      }
    },

    // Finds the common type from the collection, and sets that on the model.
    setType() {
      this.model.set({type: this.collection.state.get('commonType')});
      return this.state.set({typeName: this.collection.state.get('typeName')});
    }
  };
};
