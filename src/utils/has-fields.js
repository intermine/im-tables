/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = function(fields) { if (fields == null) { fields = []; } return model => fields.every(f => model.has(f)); };
