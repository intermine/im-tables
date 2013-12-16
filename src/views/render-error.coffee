error = require '../templates/error'
$ = require 'zepto-browserify'

module.exports = renderError = (dest) -> (err) -> $(dest).html error message: err
