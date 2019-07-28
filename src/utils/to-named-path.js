// PathInfo -> Promise<{path :: String, name :: String}>
let toNamedPath;
module.exports = (toNamedPath = p => p.getDisplayName().then(name => ({path: p.toString(), name})) );
