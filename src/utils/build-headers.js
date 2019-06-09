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
const createColumns = require('./create-columns');
const isKeyField = require('./is-key-field');
const getReplacedTest = require('./get-replaced-test');
const Formatting = require('../formatting');

// We can use a formatter if it hasn't been blacklisted.
//:: Collection -> Function -> bool
const notBanned = blacklist => formatter => !blacklist.findWhere({formatter});

//:: Function<a, b> -> Function<b, bool> -> b?
const returnIfOK = (f, test) => function(x) {
  const r = f(x);
  if (test(r)) { return r; } else { return null; }
} ;

// Add an `index` property to each object, recording its position in the array.
//:: [Object] -> ()
const index = xs => Array.from(xs).map((x, i) =>
  (x.index = i)) ;

// Calculate the headers based on the views in the query.
// For this we need the class keys.
//
// It should be noted that this is both a rather inefficient way
// to do this (we loop over the columns multiple times), but also
// that the set is very small (the view list cannot in any practical
// sense get huge), so it is very unlikely to become a bottleneck.
//
// This is more complex (and less efficient) than build-skipset but it has
// features necessary for column headers, specifically the need to record
// what the column is replacing, and operating without access to the actual
// data.
//
// :: (Query, Collection) -> Promise
module.exports = (query, banList) => query.service.fetchClassKeys().then(function(classKeys) {
  // A function that tests a path to see if it is a key field.
  let replaced;
  let col;
  const keyField = isKeyField(classKeys);
  // This holds a mapping from query views to the column that replaces them due to
  // formatting only.
  const replacedBy = {};
  // This holds a mapping from the replaced path to the column that replaces it,
  // including replacements from sub-tables.
  const explicitReplacements = {};
  // both get a formatter, and check we can use it.
  const getFormatter = returnIfOK(Formatting.getFormatter, notBanned(banList));

  // Create the columns :: [{path :: PathInfo, replaces :: [PathInfo]}]
  const cols = createColumns(query);

  // Find formatters for the attribute columns (i.e. not the outer-joined
  // collections) and if those formatters specify which columns they replace,
  // add those paths to the replacement info for that column.
  // The replacement info is specified as an array of headless paths (e.g:
  // ['start', 'end', 'locatedOn.primaryIdentifier']). As we do this, record
  // which was the first column encountered that replaces each given column.
  for (col of Array.from(cols)) {
    var fmtr;
    if (col.path.isAttribute() && (fmtr = getFormatter(col.path))) {
      col.isFormatted = true;
      col.formatter = fmtr;
      const parent = col.path.getParent();
      for (replaced of Array.from((fmtr.replaces != null ? fmtr.replaces : []))) {
        const subPath = `${ parent }.${ replaced }`;
        // That path is replaced by this column.
        if (replacedBy[subPath] == null) { replacedBy[subPath] = col; }
        // This column replaces that subpath if the subpath is in the view.
        if (Array.from(query.views).includes(subPath)) { col.replaces.push(query.makePath(subPath)); }
      }
    }
  }

  // Build the explicit replacement information, indexing which column replaces which
  // view path either due to formatting or due to outer-join sub-tables, where
  // replaces is the list of query.views that this column replaces.
  for (col of Array.from(cols)) {
    for (replaced of Array.from(col.replaces)) {
      explicitReplacements[replaced] = col;
    }
  }

  // Define a filter that weeds out view paths that are in fact handled by the
  // formatter registered on another column. This means that the final list of
  // headers can in fact be shorter than the actual view, collapsing two or more
  // columns down onto a single column.
  const isReplaced = getReplacedTest(replacedBy, explicitReplacements);

  // OK, now filter out the columns that have been replaced.
  const newHeaders = (() => {
    const result = [];
    for (col of Array.from(cols)) {
      if (!isReplaced(col)) {
        if (col.isFormatted) {
          // Ensure that the column.replaces info contains the column's path.
          if (!Array.from(col.replaces).includes(col.path)) { col.replaces.push(col.path); }
          // Raise the path to its parent if it is a key field, or it is composed.
          if ((keyField(col.path)) || (col.replaces.length > 1)) { col.path = col.path.getParent(); }
        }
        result.push(col);
      }
    }
    return result;
  })();

  // Apply the correct index to each header.
  index(newHeaders);

  return newHeaders;
}) ;

