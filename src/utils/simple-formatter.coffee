{compose, escape} = require 'underscore'
getData = require './ensure-required-data'

# :: (String, [String], (Object -> String)) -> (Backbone.Model, imjs.Service) -> String
# Takes a class name, a list of fields that the formatted object will need, and a
# function that produces a raw, unescaped string from the complete object
# and returns a Formatter (ie. a callable which takes a Model and Service and
# returns a string.
module.exports = (type, fields, f) -> compose escape, f, getData type, fields
