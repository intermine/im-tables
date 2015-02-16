_ = require 'underscore'

# Build a props object with the returned data,
# returning empty object if nothing found.
buildProps = (fs) -> (vs) -> if vs then _.object(_.zip fs, vs) else {}

# The paths in the view which have a reference
refs = (fs) -> _.flatten((refsIn f) for f in fs when (~f.indexOf '.'))

# For x.y.z return [x, x.y]
refsIn = (f) ->
  parts = f.split '.'
  (parts.slice(0, i).join('.') for i in [1 ... parts.length])

# Helper that produces functions that take a service and an id for a type,
# and fetch objects that have fields as their keys and the corresponding values
# for the object as their values.
#
# eg.
#   fetch = fetchMissingData 'Gene', ['symbol', 'organism.name']
#   fetch(service, 123).then (props) -> # {symbol: 'x', 'organism.name': 'y'}
module.exports = (type, fields, cache = {}) -> (service, id) ->
  key = service.root + '#' + id
  cache[key] ?= do ->
    service.rows select: fields, from: type, where: {id}, joins: (refs fields)
           .then _.compose (buildProps fields), _.head
