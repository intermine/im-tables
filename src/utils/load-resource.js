/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const $ = require('jquery');
const {Promise} = require('es6-promise');

const Options = require('../options');

module.exports = function(key, varName) {
  if (global[varName]) {
    return Promise.resolve(global[varName]);
  } else {
    return Promise.resolve($.ajax({url: Options.get(key), cache: true, dataType: 'script'}))
           .then(() => global[varName]);
  }
};
