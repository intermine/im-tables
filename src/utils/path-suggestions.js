/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let getPathSuggestions;
const _ = require('underscore');
const {Promise} = require('es6-promise');

// Suggestions can be very large and expensive.
const CACHE = {};

const matchPathsToNames = paths => names =>
  (() => {
    const result = [];
    for (let [path, name] of Array.from(_.zip(paths, names))) {       result.push({path, name});
    }
    return result;
  })()
 ;

module.exports = (getPathSuggestions = function(query, depth) {
  let p;
  const key = `${ query.service.root }:${ query.root }:${ depth }`;
  if (key in CACHE) { return CACHE[key]; }
  let paths = ((() => {
    const result = [];
    for (p of Array.from(query.getPossiblePaths(depth))) {       result.push(query.makePath(p));
    }
    return result;
  })());
  paths = paths.filter(p => !((p.end != null ? p.end.name : undefined) === 'id'));
  const namings = ((() => {
    const result1 = [];
    for (p of Array.from(paths)) {       result1.push(p.getDisplayName());
    }
    return result1;
  })());
  return CACHE[key] != null ? CACHE[key] : (CACHE[key] = Promise.all(namings).then(matchPathsToNames(paths)));
});
