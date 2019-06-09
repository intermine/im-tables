/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
exports.suppress = function(e) { if (e != null) {
  e.preventDefault();
} return (e != null ? e.stopPropagation() : undefined); };
