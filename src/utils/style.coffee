$ = require 'jquery'
options = require '../options'

exports.getContainer = (el) -> el.closest '.' + options.StylePrefix

exports.addStylePrefix = (x) -> (elem) -> $(elem).addClass(options.StylePrefix); x
