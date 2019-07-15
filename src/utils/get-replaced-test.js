let getReplacedTest;
const {shouldFormat} = require('../formatting');

const isIDPath = p => p.isAttribute() && (p.end.name === 'id');

// Return whether a column is replaced by another.
// :: ({string: Column}) -> (Column) -> bool
module.exports = (getReplacedTest = (formatReplacements, allReplacements) => function(col) {
  if (col == null) { throw new Error('no column'); }
  const p = col.path; // we perform lookups by path.
  if ((!shouldFormat(p)) && (!(p in allReplacements))) { return false; }
  // Find the path that replaces this one by its name, or by its parent's name, if this
  // is the id path.
  let replacer = formatReplacements[p];
  if (isIDPath(p)) { if (replacer == null) { replacer = formatReplacements[p.getParent()]; } }
  // Finally check that there is in fact a valid replacer that does formatting, and
  // that it isn't in fact this same path.
  return replacer && (replacer.formatter != null) && (col !== replacer);
} );

