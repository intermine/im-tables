_ = require 'underscore'

simpleFormatter = require 'imtables/utils/simple-formatter'
template = _.template '<%= manager.title %> <%= manager.name %>', variable: 'manager'

module.exports = simpleFormatter 'Company', ['title', 'name'], template

