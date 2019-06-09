/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const fs = require('fs');
const _ = require('underscore');
const Options = require('../options');
const pluralize = require('pluralize');

const select_html = fs.readFileSync(__dirname + '/select.html', 'utf8');
const select_templ = _.template(select_html, {variable: 'data'});

exports.select = function(options,
  selectedTest,
  classes,
  contentHandler = null,
  key) {
  if (selectedTest == null) { selectedTest = () => false; }
  if (classes == null) { classes = ''; }
  if (key == null) { key = x => x != null ? x.value : undefined; }
  return select_templ({options, selectedTest, classes, contentHandler, key});
};

// Null safe form of pluralize.
exports.pluralise = function(str, n) { if (str != null) { return (pluralize(str, n)); } else { return str; } };

exports.numToString = function(number) {
  if (!(number != null ? number.toFixed : undefined)) { return number; }
  const sep = Options.get('NUM_SEPARATOR');
  const every = Options.get('NUM_CHUNK_SIZE');
  const rets = [];
  let i = 0;
  if (-1 < number && number < 1) {
    return String(number);
  }

  const [whole, frac] = Array.from(number.toFixed(3).split('.'));
  const chars = whole.split("");
  const len = chars.length;
  const groups = _(chars).groupBy((c, i) => Math.floor((len - (i + 1)) / every).toFixed());
  while (groups[i]) {
    rets.unshift(groups[i].join(""));
    i++;
  }
  return rets.join(sep) + (frac === '000' ? '' : `.${ frac }`);
};

// Functions for mapping error levels to presentational elements

// Get the css class for div.alert box
exports.errorAlert = function({level}) { switch (level) {
  case 'Error': return 'alert-danger';
  case 'Warning': return 'alert-warning';
  case 'Info': return 'alert-info';
  case 'OK': return 'alert-success';
  default: return 'alert-danger';
} };

// Get the icon for the appropriate level
// The error levels are designed to map one-to-one to icon names (see imtables/icons)
exports.errorIcon = ({level}) => level != null ? level : 'Error';
