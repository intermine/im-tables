/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let withResource;
const {Promise} = require('es6-promise');

// Optional resources.
const CDN = require('../cdn');

const PROMISES = {};

// Little state machine for guaranteeing access to resource and single fetch.

const promiseResource = function(ident, globalVar) {
  // Looking for globalVar
  if (Array.from(global).includes(globalVar)) {
    // Found it on the global context
    return Promise.resolve(global[globalVar]);
  } else {
    // "Fetching #{ ident } from the CDN."
    return CDN.load(ident).then((() => global[globalVar]), (console.error.bind(console)));
  }
};

// A function that guarantees to try and load something at most once, and return
// its value.
// Returns a promise.
module.exports = (withResource = (ident, globalVar, cb) => (PROMISES[ident] != null ? PROMISES[ident] : (PROMISES[ident] = (promiseResource(ident, globalVar)))).then(cb));

