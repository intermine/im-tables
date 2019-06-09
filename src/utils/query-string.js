/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// ([[name, val]]) -> string
exports.fromPairs = pairs => (Array.from(pairs).map((p) => p.map(encodeURIComponent).join('='))).join('&');

