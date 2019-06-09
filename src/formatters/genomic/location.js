// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let FIELDS;
const simpleFormatter = require('../../utils/simple-formatter');

const [chr] = Array.from((FIELDS = ['locatedOn.primaryIdentifier', 'start', 'end']));
const formatter = loc => `${ loc[chr] }:${ loc.start }..${ loc.end }`;
const classes = 'monospace-text';

module.exports = simpleFormatter('Location', FIELDS, formatter, classes);
