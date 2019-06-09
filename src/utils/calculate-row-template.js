/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Analyse the select list to establish what the columns are going to be,
// based on the outer joined structure.

// Find the highest outer-joined collection below a given value.
let calculateRowTemplate;
const getOJCBelow = function(query, p, below) {
  const oj = query.getOuterJoin(p);
  if ((!oj) || (oj === below)) { return null; } // not outerjoined, or joined at the target level.
  let path = query.makePath(oj);
  // outer loop variables.
  let highest = path.isCollection() ? oj : null;
  path = path.getParent();

  while (path && (!path.isRoot())) { (function(next) {
    let nextPath;
    if (next != null) { nextPath = query.makePath(next); }
    if ((nextPath != null ? nextPath.isCollection() : undefined) && (next !== below)) { highest = next; }
    return path = nextPath != null ? nextPath.getParent() : undefined;
  })(query.getOuterJoin(path)); }

  return highest;
};

const getTopLevelOJC = (query, p) => getOJCBelow(query, p, null);

module.exports = (calculateRowTemplate = function(query) {
  const row = [];
  const handled = {};
  for (let v of Array.from(query.views)) {
    if (!handled[v]) {
      var oj = getTopLevelOJC(query, v);
      if (oj) {
        const coevals = query.views.filter(vv => oj === getTopLevelOJC(query, vv));
        const group = {column: oj, view: []};
        for (let cv of Array.from(coevals)) { // Either add subviews or subgroups.
          const lower = getOJCBelow(query, cv, oj); // Find the highest oj for this path below the top level.
          handled[cv] = group; // This view is handled by this group.
          if (lower) {
            if (!Array.from(group.view).includes(lower)) { group.view.push(lower); } // only add once.
          } else {
            group.view.push(cv);
          }
        }
        row.push(handled[oj] = group);
      } else {
        row.push(handled[v] = {column: v});
      }
    }
  }
  return row;
});

