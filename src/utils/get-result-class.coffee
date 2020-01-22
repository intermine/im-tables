{Promise} = require 'es6-promise'

# (Query) -> Promise<String>
# Gets the class that defines the query, or the name of the model, or the empty string.
# It is perhaps a matter for debate whether we should send Galaxy the
# display names, or the class names..
module.exports = getResultClass = (query) -> new Promise (resolve, reject) ->
  viewNodes = query.getViewNodes()
  {model} = query
  resolve if commonType = model.findCommonType(node.getType() for node in viewNodes)
    model.getPathInfo(commonType).getDisplayName()
  else
    (model.name ? '')
