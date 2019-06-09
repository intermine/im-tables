// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

const contains_i = (a, b) => a.toLowerCase().indexOf(b) >= 0;

// Expects an array or collection of suggestions of the form {path, name}
module.exports = suggestions => function(term, cb) {
  let left;
  const parts = ((left = __guard__(term != null ? term.toLowerCase() : undefined, x => x.split(' '))) != null ? left : []);
  const matches = ({path, item, name}) => _.all(parts, function(p) {
    if (path == null) { path = item; }
    return contains_i(path.toString(), p) || contains_i(name, p);
  }) ;
  if (suggestions.each != null) {
    return cb(suggestions.map(sm => sm.toJSON()).filter(matches));
  } else {
    return cb((() => {
      const result = [];
      for (let s of Array.from(suggestions)) {         if (matches(s)) {
          result.push(s);
        }
      }
      return result;
    })());
  }
} ;

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}