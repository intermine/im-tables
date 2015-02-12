_ = require 'underscore'

simpleFormatter = require 'imtables/utils/simple-formatter'

module.exports = simpleFormatter 'Company', ['name', 'vatNumber'], (company) ->
  "#{ company.name } (vat no. #{ company.vatNumber })"

