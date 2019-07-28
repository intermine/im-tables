let FIELDS;
const simpleFormatter = require('../../utils/simple-formatter');

const [chr] = Array.from((FIELDS = ['locatedOn.primaryIdentifier', 'start', 'end']));
const formatter = loc => `${ loc[chr] }:${ loc.start }..${ loc.end }`;
const classes = 'monospace-text';

module.exports = simpleFormatter('Location', FIELDS, formatter, classes);
