// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let createColumns;
const longestCommonPrefix = require('./longest-common-prefix');
const structure = require('./calculate-row-template');

// Create the columns
//
// A column is either a simple column (path is column, empty replaces), or an
// outer-joined collection (where the replaces is the view of the sub-table,
// and the path is the longest common prefix of that view).
//
// :: Query -> [Column]
// where Column == {path :: PathInfo, subview :: Paths, replaces :: Paths}
//       Paths == [PathInfo]
module.exports = (createColumns = query => structure(query).map(function(cell) {
  let path, replaces, subview;
  let v;
  if (cell.view != null) { // subtable.
    // The column is the highest outer-joined collection, which will, in
    // 99% of cases also be the LCP. However, it is possible for the 
    // LCP to be something deeper - e.g: within the outer-joined-coll'n
    // 'Company.departments' if the subviews arE '~.employees.*' etc,
    // with none of the department's attributes selected,
    // then it makes more sense to say this is a collection of employees
    // than a collection of departments. In fact, this will also lift a subtable of
    // a single column to that column, so that a subtable of '~.employees.name'
    // will be labelled as 'Employee Names'
    const commonPrefix = longestCommonPrefix(cell.view);
    path = query.makePath(commonPrefix);
    subview = ((() => {
      const result = [];
      for (v of Array.from(cell.view)) {         result.push(query.makePath(v));
      }
      return result;
    })());
    replaces = ((() => {
      const result1 = [];
      for (v of Array.from(query.views)) {         if (0 === v.indexOf(commonPrefix)) {
          result1.push(query.makePath(v));
        }
      }
      return result1;
    })());
  } else { // A single value column.
    path = query.makePath(cell.column);
    subview = null; // This column does not have a subview.
    replaces = []; // It doesn't replace anything, either (yet!)
  }

  // Now why do normal value columns have subviews and replacement lists, 
  // I hear you plaintively whimper? Well, it is because they may replace
  // *other* columns through the use of formatters, thus presenting
  // more like outer-joined-collections than single value columns (they
  // will be marked as composed and formatted, in that case).

  return {path, subview, replaces};}) );

