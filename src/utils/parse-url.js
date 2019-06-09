/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

const pairsToParams = pairs => _.object(Array.from(pairs).map((p) => p.split('=').map(decodeURIComponent)));

module.exports = function(url) {
  const [URL, qs] = Array.from(url.split('?'));
  const pairs = qs.split('&');
  const params = pairsToParams(pairs);
  return {URL, params};
};

