_ = require 'underscore'

simpleFormatter = require 'imtables/utils/simple-formatter'
template = _.template '<%= m.title %> <%= m.name %>', variable: 'm'

module.exports = simpleFormatter 'Manager', ['title', 'name'], template

