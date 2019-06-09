// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
exports.href = function(address, subject, body) {
  const pairs = [['subject', subject], ['body', body]];
  const params = pairs.map(function(...args) { const [k, v] = Array.from(args[0]); return `${ k }=${ encodeURIComponent(v) }`; })
                .join('&');
  return address + '?' + params;
};

