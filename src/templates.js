var _ = require('underscore');
var fs = require('fs');
var TEMPLATES = exports;
exports.template = function (name, opts) {
  return _.template(getTemplate(name), opts);
};
exports.templateFromParts = function (names, opts) {
  var src = names.map(getTemplate).join("\n");
  return _.template(src, opts);
};
function getTemplate (name) {
  return TEMPLATES[name];
}
