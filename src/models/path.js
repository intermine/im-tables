let PathModel;
const CoreModel = require('../core-model');

const {Model: {NUMERIC_TYPES, BOOLEAN_TYPES}} = require('imjs');

module.exports = (PathModel = class PathModel extends CoreModel {

  defaults() {
    return {
      path: null,
      type: null,
      displayName: null,
      typeName: null,
      parts: [],
      isNumeric: false,
      isBoolean: false,
      isReference: false, // Assumes attribute by default
      isAttribute: true
    };
  }

  constructor(path) {
    super();
    this.set(this.pathAttributes(path));
    this.setDisplayName(path);
    this.setTypeName(path);
    this.pathInfo = () => path;
    // Freeze the things that should never change
    this.freeze('path', 'isNumeric', 'isBoolean', 'isReference', 'isAttribute');
  }

  setDisplayName(path) {
    return path.getDisplayName().then(name => {
      this.set({displayName: name, parts: name.split(' > ')});
      return this.freeze('displayName', 'parts');
    });
  }

  setTypeName(path) {
    const type = (path.isAttribute() ? path.getParent() : path).getType();
    return type.getDisplayName().then(name => this.set({typeName: name}));
  }

  pathAttributes(path) {
    const str = String(path);
    const isAttr = path.isAttribute();
    const type = path.getType();
    const attrs = {
      id: (isAttr ? str : `${ str }.id`),
      path: str,
      type: (type.name != null ? type.name : type)
    };

    if (isAttr) {
      attrs.isNumeric = (Array.from(NUMERIC_TYPES).includes(type));
      attrs.isBoolean = (Array.from(BOOLEAN_TYPES).includes(type));
    } else {
      attrs.isReference = true;
      attrs.isAttribute = false;
    }

    return attrs;
  }
});
