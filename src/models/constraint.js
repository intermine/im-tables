// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ConstraintModel;
const _ = require('underscore');

const {Query: {LIST_OPS, LOOP_OPS, TERNARY_OPS, RANGE_OPS, NULL_OPS}} = require('imjs');

const PathModel = require('./path');

const constraintType = function(opts) {
  if (opts.path.isAttribute()) {
    if (opts.values) { return 'MULTI_VALUE'; }
    return 'ATTR_VALUE';
  } else {
    if (opts.type) { return 'TYPE'; }
    if (opts.ids) { return 'IDS'; }
    if (opts.values && (Array.from(RANGE_OPS).includes(opts.op))) { return 'RANGE'; }
    if (Array.from(TERNARY_OPS).includes(opts.op)) { return 'LOOKUP'; }
    if (Array.from(LIST_OPS).includes(opts.op)) { return 'LIST'; }
    if (Array.from(LOOP_OPS).includes(opts.op)) { return 'LOOP'; }
    if (Array.from(NULL_OPS).includes(opts.op)) { return opts.op; }
  }
  throw new Error(`Cannot determine constraint type: ${ opts.path } ${ opts.op }`);
};

// A rather ugly but convenient reutilisation of PathModel
// to provide the displayName etc conveniences in ConstraintModel.
// The two difficulties are making sure the id is unique (as
// constraints can have the same path) and avoiding conflicts with type.
//
// Future work might want to improve this.
module.exports = (ConstraintModel = class ConstraintModel extends PathModel {

  defaults() { return _.extend(super.defaults(...arguments), {
    value: null,
    values: [],
    ids: [],
    extraValue: null,
    code: null,
    CONSTRAINT_TYPE: 'ATTR_VALUE'
  }
  ); }

  constructor(opts) {
    super(opts.path);
    const { type } = opts;
    this.unset('id');
    this.unset('type');
    this.set((_.omit(opts, 'path', 'type')));
    if (type != null) {
      this.set({type: type.toString()});
      type.getDisplayName().then(name => this.set({typeName: name}));
    }

    this.set({CONSTRAINT_TYPE: constraintType(opts)});
  }
});
