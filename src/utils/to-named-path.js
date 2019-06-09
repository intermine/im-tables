/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// PathInfo -> Promise<{path :: String, name :: String}>
let toNamedPath;
module.exports = (toNamedPath = p => p.getDisplayName().then(name => ({path: p.toString(), name})) );
