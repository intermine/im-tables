$ = require 'jquery'
{Promise} = require 'es6-promise'

Options = require '../options'

module.exports = (url, filename, onProgress) ->
  Promise.reject new Error 'still in progress'

