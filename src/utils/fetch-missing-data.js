/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

// Build a props object with the returned data,
// returning empty object if nothing found.
const buildProps = fs => function(vs) { if (vs) { return _.object(_.zip(fs, vs)); } else { return {}; } };

// The paths in the view which have a reference
const refs = fs => _.flatten((() => {
  const result = [];
  for (let f of Array.from(fs)) {     if (~f.indexOf('.')) {
      result.push((refsIn(f)));
    }
  }
  return result;
})()) ;

// For x.y.z return [x, x.y]
var refsIn = function(f) {
  const parts = f.split('.');
  return (__range__(1, parts.length, false).map((i) => parts.slice(0, i).join('.')));
};

// Helper that produces functions that take a service and an id for a type,
// and fetch objects that have fields as their keys and the corresponding values
// for the object as their values.
//
// eg.
//   fetch = fetchMissingData 'Gene', ['symbol', 'organism.name']
//   fetch(service, 123).then (props) -> # {symbol: 'x', 'organism.name': 'y'}
module.exports = function(type, fields, cache) { if (cache == null) { cache = {}; } return function(service, id) {
  const key = service.root + '#' + id;
  return cache[key] != null ? cache[key] : (cache[key] = (() =>
    service.rows({select: fields, from: type, where: {id}, joins: (refs(fields))})
           .then(_.compose((buildProps(fields)), _.head))
  )());
}; };

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}