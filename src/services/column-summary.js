const CACHE = {};

const getKey = (query, path) => `${ query.service.root }:${ query.service.token }:${ query.toXML() }:${ path }`;

// (imjs.Query, String) -> Promise<Summary>
exports.getColumnSummary = function(query, path, term, limit) {
  let name;
  return CACHE[name = getKey(query, path, term, limit)] != null ? CACHE[name] : (CACHE[name] = (() => query.filterSummary(path, term, limit))());
};

