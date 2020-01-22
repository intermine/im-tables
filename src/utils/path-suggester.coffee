_ = require 'underscore'

contains_i = (a, b) -> a.toLowerCase().indexOf(b) >= 0

# Expects an array or collection of suggestions of the form {path, name}
module.exports = (suggestions) -> (term, cb) ->
  parts = (term?.toLowerCase()?.split(' ') ? [])
  matches = ({path, item, name}) -> _.all parts, (p) ->
    path ?= item
    contains_i(path.toString(), p) or contains_i(name, p)
  if suggestions.each?
    cb(suggestions.map((sm) -> sm.toJSON()).filter(matches))
  else
    cb(s for s in suggestions when matches s)
