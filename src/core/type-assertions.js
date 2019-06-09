// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let ArrayOf, Callable, DataModel, InterMineService, IsArray, StringType;
const _ = require('underscore');
const Backbone = require('backbone');

const CoreModel = require('../core-model');
const CoreCollection = require('./collection');

exports.assertMatch = function(assertion, value, paramName) {
  if (paramName == null) { paramName = 'value'; }
  const isOk = assertion.test(value);
  if (!isOk) {
    throw new Error(assertion.message(paramName));
  }
};

class InstanceOfAssertion {

  constructor(type, name) {
    this.type = type;
    this.name = name;
    if (!(this instanceof InstanceOfAssertion)) { // Allow construction without `new`
      return new InstanceOfAssertion(this.type, this.name);
    }
  }

  test(m) { return m instanceof this.type; }

  message(p) { return `${ p } is not an instance of ${ this.name }`; }
}

// Arbitrarily nested type assertions.
class StructuralTypeAssertion {

  constructor(name, structure) {
    this.name = name;
    this.structure = structure;
    this._msg = null; // set during test, cleared during message
  }

  failValidation(msg) {
    this._msg = msg;
    return false;
  }

  test(v) {
    this._msg = null;
    if ((v == null)) {
      return this.failValidation('it is null');
    }
    if (v == null) { return false; }
    for (let propName in this.structure) {
      const subtest = this.structure[propName];
      const prop = v[propName];
      const propIsOk = subtest.test(prop);
      if (!propIsOk) {
        return this.failValidation(subtest.message(`.${ propName }`));
      }
    }
    return true;
  }

  message(p) { return `${ p } failed ${ this.name } validation, because ${ this._msg }`; }
}

exports.InstanceOf = InstanceOfAssertion;

exports.Structure = StructuralTypeAssertion;

// Check that something is a model.
exports.Model = new InstanceOfAssertion(Backbone.Model, 'Backbone.Model');

// Check that something is a core-model.
exports.CoreModel = new InstanceOfAssertion(CoreModel, 'core-model');

// Check that something is a collection.
exports.CoreCollection = new InstanceOfAssertion(CoreCollection, 'core/collection');

// Check that something is an array.
exports.Array = (IsArray = {
  name: 'array',
  test: _.isArray,
  message(p) { return `${ p } is not an array`; }
});

exports.ArrayOf = (ArrayOf = function(elem) {
  return {
    name: `array of ${ elem.name }`,
    test(v) { return this.passed = (IsArray.test(v)) && (_.all(v, elem.test)); },
    message(p) {
      return `${ p } is not an array of ${ elem.name != null ? elem.name : 'the correct type' }`;
    }
  };
});

// Check that something is a function.
exports.Function = {
  name: 'function',
  test: _.isFunction,
  message(p) { return `${ p } is not a function`; }
};

// Check that something is a number
exports.Number = {
  name: 'number',
  test: _.isNumber,
  message(p) { return `${ p } is not a number`; }
};

// Check that something is a string
exports.String = (StringType = {
  name: 'string',
  test: _.isString,
  message(p) { return `${ p } is not a string`; }
});

// Test if something is either null or that it passes a type-assertion.
exports.Maybe = assertion =>
  ({
    name: `maybe ${ assertion.name }`,
    test(v) { return ((v == null)) || (assertion.test(v)); },
    message(p) { return assertion.message(p); } // If not null, then the assertion will know what is wrong.
  })
;

// Test that something has a call method - (like a function).
exports.Callable = (Callable = {
  name: 'callable',
  test(v) { return (v != null) && _.isFunction(v.call); },
  message(p) { return `${ p } is not callable`; }
});

exports.HasProperty = prop =>
  ({
    name: `has-property(${ prop })`,
    test(v) { return (v != null) && prop in v; },
    message(p) { return `${ p }.${ prop } not found`; }
  })
;

exports.UnionOf = function(...types) {
  return {
    name() { return `Union of ${ types.map(t => t.name).join(', ') }`; },
    test(v) { return _.all(types, t => { this._t = t; return t.test(v); }); },
    message(p) { return (this._t != null ? this._t.message(p) : undefined); }
  };
};

// If this module gets published, the stuff below should stay with
// this repo.

// A structural type for detecting queries.
// This is a structural type and not an instance-of type
// because this library will support external provision
// of queries (possibly constructed with different classes)
// and it would be good to support mocking more easily too.
//
// The selected properties do not represent the full public
// API of these classes, but they should be more than enough to
// positively identify instances of them with a very low chance
// of false positives, and zero false negatives.

exports.Listenable = new StructuralTypeAssertion('Listenable', {
  on: exports.Function,
  off: exports.Function
}
);

exports.Service = (InterMineService = new StructuralTypeAssertion('Service', {
  root: StringType,
  query: Callable,
  fetchModel: Callable,
  fetchLists: Callable,
  count: Callable,
  whoami: Callable
}
));

exports.DataModel = (DataModel = new StructuralTypeAssertion('imjs.Model', {
  name: StringType,
  makePath: Callable,
  findCommonType: Callable
}
));

exports.Query = new StructuralTypeAssertion('Query', {
  service: InterMineService,
  model: DataModel,
  rows: Callable,
  count: Callable,
  toXML: Callable,
  root: StringType,
  views: (ArrayOf(StringType))
}
);

