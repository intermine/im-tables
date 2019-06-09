// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Compact multiple empty lines and trim
let stripExtraneousWhiteSpace;
module.exports = (stripExtraneousWhiteSpace = function(str) {
  if (str == null) { return; }
  str = str.replace(/\n\s*\n/g, '\n\n');
  return str.replace(/(^\s*|\s*$)/g, '');
});

