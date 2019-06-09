/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require('underscore');

const {Model: {NUMERIC_TYPES}} = require('imjs');

const NumericFacet = require('./facets/numeric');
const FrequencyFacet = require('./facets/frequency');

// Factory function that returns the appropriate type of summary based on the
// type of the path (numeric or non-numeric).
exports.create = function(args) {
  return new FrequencyFacet(args); // remove this factory??

  const path = args.view;
  const attrType = path.getType();
  const initialLimit = Options.get('INITIAL_SUMMARY_ROWS');
  const Facet = Array.from(NUMERIC_TYPES).includes(attrType) ?
    NumericFacet // FIXME FIXME - combine into FrequencyFacet!!
  :
    FrequencyFacet;

  return new Facet(args);
};

