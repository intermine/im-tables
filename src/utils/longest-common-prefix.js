// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let longestCommonPrefix;
const _ = require('underscore');

const prefixesAll = xs => prefix => _.all(xs, x => 0 === x.indexOf(prefix));

// Find the longest common prefix from an array of paths as strings.
// :: [string] -> string
module.exports = (longestCommonPrefix = function(...args) {
  const [head, ...tail] = Array.from(args[0]);
  if (head == null) { throw new Error('Empty list'); }
  if (!tail.length) { return head; } // lcp of single item list is that item.
  const parts = head.split(/\./);
  // We only need to test the tail, since we know that the parts come from the head.
  const test = prefixesAll(tail);

  let [prefix] = Array.from(parts); // Root, must be common prefix.
  for (let part of Array.from(parts)) {
    var nextPrefix;
    if (test(nextPrefix = `${prefix}.${part}`)) {
      prefix = nextPrefix;
    }
  }
  return prefix;
});

