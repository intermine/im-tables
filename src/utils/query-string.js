// ([[name, val]]) -> string
exports.fromPairs = pairs => (Array.from(pairs).map((p) => p.map(encodeURIComponent).join('='))).join('&');

