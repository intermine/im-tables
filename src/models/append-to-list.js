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
