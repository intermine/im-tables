/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let enableFormatter, getFormatter;
const _ = require('underscore');
const Templates = require('./templates');
const NestedModel = require('./core/nested-model');

// This module provides logic for finding formatters registered for specific
// paths.  The semantics are that formatters are functions that are used to
// format a cell, and these are registered for one or more fields of an object.
// e.g: A formatter may handle ChromosomeLocation objects, but only handle the
// .start and .end fields, leaving .strand alone. In this case then the format
// set should have an entry at 'ChromosomeLocation' for the formatter, and one
// at 'ChromosomeLocation.start' and 'ChromosomeLocation.end' each with the
// value `true`, indicating that the formatter is to be looked up by class name.
// If on the other hand the formatter is meant to handle all paths, then a
// short-cut of 'ChromosomeLocation.*' can be used, which will match against all
// paths. As a convenience, the formatter can also be registered at that key,
// rather than needing a second lookup.
//
// This module manages a formatter registry, wrapped in a NestedModel, providing
// accessors to find appropriate formatters and register new ones.

// Return the last class descriptor for a path. e.g: for 'Employee.name' return Employee,
// and for 'Employee.department' return Department.
// :: PathInfo -> Table
const lastCd = function(path) {
  if (path.isAttribute()) { return path.getParent().getType(); } else { return path.getType(); }
};

// Get the full bottom up inheritance hierarchy, including the class itself.
// :: PathInfo -> [string]
const getAncestors = function(path) {
  const cd = lastCd(path);
  return [cd.name].concat(path.model.getAncestorsOf(cd));
};

const bool = x => !!x; // boolean type coercion.

// We store the formatters here.
const formatters = new NestedModel;

// Get the formatter for a given path, or null if there isn't one, or false it is disabled.
// :: PathInfo -> Function | null | false
exports.getFormatter = (getFormatter = function(path) {
  let left;
  if (((path == null)) || path.isRoot()) { throw new Error('No path or path is root'); }

  const { model }         = path; // we need to query the path's model.
  const formattersFor = ((left = formatters.get([model.name]))) != null ? left : {};
  const ancestors     = getAncestors(path);
  const fieldName     = path.end.name; // eg. 'name', 'employees'

  for (let a of Array.from(ancestors)) {
    // find formatters registered against specific fields or whole classes.
    // formatters must be registed in this way to apply to one or more paths.
    // Note that we prefer the specifically registered formatter to the general one.
    let formatter = (formattersFor[`${ a }.${ fieldName }`] || formattersFor[`${ a }.*`] );
    if (formatter === true) {
      // formatters are either a function or a boolean - if true, then we can lookup
      // against the class name itself.
      formatter = formattersFor[a];
    }
    if (formatter != null) { return formatter; }
  } // if set to `false` then we short-cut nicely.
  return null;
});

// Return true if we should format a path.
// This is a convenience for a null check on a formatter retrieval, along with
// an attribute check.
// :: (PathInfo) -> bool
exports.shouldFormat = function(path) {
  if (path == null) { throw new Error('no path'); }
  if (!path.isAttribute()) { return false; } // we should only format attributes.
  // We should format if there is a formatter available to use (and it isn't disabled).
  return bool(getFormatter(path));
};

// Register a formatter capable of formatting objects of type `type` in
// `modelName` models, activated by the `paths`.
//
// If there is just a single path listed, then the formatter will be registered
// at that path only, otherwise it will be registered at the type and each path will
// be listed as an activation path.
//
// No validation is done on the model and path name. The formatter must be a function,
// however (well, functionish, it is called using the `call` syntax, so that is
// all we check for, making it possible to register an instance of a class if you want
// as long as it has a `call` method with the same signature as Function::call.
exports.registerFormatter = function(formatter, model, type, paths) {
  if (paths == null) { paths = ['*']; }
  if ((formatter != null ? formatter.call : undefined) == null) { throw new Error('formatter is not a function'); }
  if ((paths.length === 1) && (paths[0] !== '*')) {
    return formatters.set([model, `${ type }.${ paths[0] }`], formatter);
  } else {
    formatters.set([model, type], formatter);
    return enableFormatter(model, type, paths);
  }
};

// Disable a formatter.
exports.disableFormatter = function(model, type, paths) {
  if (paths == null) { paths = ['*']; }
  return Array.from(paths).map((p) =>
    formatters.set([model, `${ type }.${ p }`], false));
};

// Get a list of the enabled formatters.
exports.list = model =>
  (() => {
    const result = [];
    const object = formatters.get([model]);
    for (let key in object) {
      const value = object[key];
      if (value) {
        result.push(key);
      }
    }
    return result;
  })()
;

// Enable a formatter.
exports.enableFormatter = (enableFormatter = function(model, type, paths) {
  if (paths == null) { paths = ['*']; }
  return Array.from(paths).map((p) =>
    formatters.set([model, `${ type }.${ p }`], true));
});

exports.defaultFormatter = function(imobject, service, value) {
  if (value != null) { return (_.escape(value)); } else { return Templates.null_value; }
};

// Clear the formatters collection.
// For use in testing.
exports.reset = function() {
  formatters.clear();
  return formatters.trigger('reset');
};

