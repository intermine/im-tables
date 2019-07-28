let ObjectStore;
const _ = require('underscore');

const IMObject = require('./intermine-object');

// A simple class to cache object construction, guaranteeing there is only ever one
// entity object for each entity. It also manages merging in the properties of the
// entities when multiple fields have been selected.
// 
// This means that a query that selects Employee.name and Employee.age will only have
// one Employee entity per employee object (keyed by id), and each object will have the
// appropriate `name` and `age` fields.
module.exports = (ObjectStore = class ObjectStore {

  constructor(root, schema) {
    this.schema = schema;
    if (root == null) { throw new Error('No root'); }
    if (this.schema == null) { throw new Error('no schema'); }
    this.base = root.replace(/\/service\/?$/, ""); // trim the /service
    this._objects = {};
  }

  get(obj, field) {
    const model = (this._objects[obj.id] != null ? this._objects[obj.id] : (this._objects[obj.id] = this._newObject(obj)));
    model.merge(obj, field);
    return model;
  }

  _newObject(obj) {
    let left;
    const classes = ((Array.from((left = (obj['class'] != null ? obj['class'].split(',') : undefined)) != null ? left : [])).map((c) => this.schema.makePath(c)));
    return new IMObject(this.base, classes, obj.id);
  }

  destroy() {
    for (let id in this._objects) {
      const model = this._objects[id];
      model.destroy();
    }
    delete this.selectedObjects;
    return delete this._objects;
  }
});

