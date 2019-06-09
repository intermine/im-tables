// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AppendToListModel;
const _ = require('underscore');
const CoreModel = require('../core-model');

module.exports = (AppendToListModel = class AppendToListModel extends CoreModel {

  // This model has a target and a type.
  defaults() {
    return {
      target: null,
      type: null
    };
  }
});
