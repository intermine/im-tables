{compose, escape} = require 'underscore'
getData = require './ensure-required-data'

# Produce a callable from a function.
callable = (f) -> (_, args...) -> f args...

# :: (String, [String], (Object -> String)) -> Formatter
# Takes a class name, a list of fields that the formatted object will need, and a
# function that produces a raw, unescaped string from the complete object
# and returns a Formatter (ie. a callable which takes a Model and Service and
# returns a string.
module.exports = (type, fields, f) ->
  target: type
  replaces: fields
  call: callable compose escape, f, getData type, fields
