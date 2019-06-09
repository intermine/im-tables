/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let getResultClass;
const {Promise} = require('es6-promise');

// (Query) -> Promise<String>
// Gets the class that defines the query, or the name of the model, or the empty string.
// It is perhaps a matter for debate whether we should send Galaxy the
// display names, or the class names..
module.exports = (getResultClass = query => new Promise(function(resolve, reject) {
  let commonType;
  const viewNodes = query.getViewNodes();
  const {model} = query;
  return resolve((commonType = model.findCommonType(Array.from(viewNodes).map((node) => node.getType()))) ?
    model.getPathInfo(commonType).getDisplayName()
  :
    (model.name != null ? model.name : '')
  );
}) );
