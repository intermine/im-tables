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