$ = require 'jquery'
{Promise} = require 'es6-promise'

Options = require '../options'

module.exports = (key, varName) ->
  if global[varName]
    Promise.resolve global[varName]
  else
    Promise.resolve($.ajax url: Options.get(key), cache: true, dataType: 'script')
           .then -> global[varName]
