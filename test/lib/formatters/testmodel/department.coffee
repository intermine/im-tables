_ = require 'underscore'

simpleFormatter = require 'imtables/utils/simple-formatter'

module.exports = simpleFormatter 'Department', ['name', 'company.name'], (d) ->
  "#{ d.name } (#{ d['company.name'] })"

