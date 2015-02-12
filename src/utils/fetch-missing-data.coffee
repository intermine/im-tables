_ = require 'underscore'

module.exports = (type, fields, cache = {}) -> (service, id) ->
  key = service.root + '#' + id
  cache[key] ?= service.findById(type, id).then (r) -> _.pick r, fields
