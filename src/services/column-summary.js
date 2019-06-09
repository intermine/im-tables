// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const CACHE = {};

const getKey = (query, path) => `${ query.service.root }:${ query.service.token }:${ query.toXML() }:${ path }`;

// (imjs.Query, String) -> Promise<Summary>
exports.getColumnSummary = function(query, path, term, limit) {
  let name;
  return CACHE[name = getKey(query, path, term, limit)] != null ? CACHE[name] : (CACHE[name] = (() => query.filterSummary(path, term, limit))());
};

