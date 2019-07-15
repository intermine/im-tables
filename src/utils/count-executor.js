// Caching query executor.

let CACHE = {};

// A unique key composed of the service we are connected to and the
// canonical representation of the query.
const key = q => `${ q.service.root }:${ q.service.token }:${ q.toXML() }`;

// Simple caching layer that caches counts.
exports.count = function(q) { let name;
return CACHE[name = key(q)] != null ? CACHE[name] : (CACHE[name] = q.count()); };

exports.clearCache = () => CACHE = {};

