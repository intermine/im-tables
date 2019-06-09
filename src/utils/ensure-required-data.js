/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const getMissingData = require('./fetch-missing-data');
const hasData        = require('./has-fields');

const thenSet = (m, p) => p.then(data => m.set(data));

// :: (type :: String, fields :: [String]) -> (m :: Model, s :: Service) -> Obj
module.exports = function(type, fields) {
  const get = getMissingData(type, fields);
  const complete = hasData(fields);
  // Setting missing props triggers re-render.
  return function(m, s) { if (!complete(m)) { thenSet(m, get(s, m.get('id'))); } return m.toJSON(); };
};
