{Promise} = require 'es6-promise'

# Optional resources.
CDN = require '../cdn'

PROMISES = {}

# Little state machine for guaranteeing access to resource and single fetch.

promiseResource = (ident, globalVar) ->
  # Looking for globalVar
  if globalVar in global
    # Found it on the global context
    Promise.resolve global[globalVar]
  else
    # Fetching it from the CDN.
    CDN.load(ident).then (-> global[globalVar]), (console.error.bind console)

# A function that guarantees to try and load something at most once, and return
# its value.
# Returns a promise.
module.exports = withResource = (ident, globalVar, cb) ->
  (PROMISES[ident] ?= (promiseResource ident, globalVar)).then cb

