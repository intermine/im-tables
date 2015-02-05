_ = require 'underscore'
CoreModel = require '../core-model'
CoreCollection = require './collection'

class InstanceOfAssertion

  constructor: (@type, @name) ->
    unless @ instanceof InstanceOfAssertion # Allow construction without `new`
      return new InstanceOfAssertion @type, @name 

  test: (m) -> m instanceof @type

  message: (p) -> "#{ p } is not an instance of #{ @name }"

exports.InstanceOf = InstanceOfAssertion

# Arbitrarily nested type assertions.
class exports.StructuralTypeAssertion

  constructor: (@name, @structure) ->
    @_msg = null # set during test, cleared during message

  failValidation: (msg) ->
    @_msg = msg
    return false

  test: (v) ->
    @_msg = null
    if not v?
      return @failValidation 'it is null'
    return false unless v?
    for propName, subtest of @structure
      prop = v[propName]
      propIsOk = subtest.test prop
      unless propIsOk
        return @failValidation subtest.message ".#{ propName }"
    return true

  message: (p) -> "#{ p } failed #{ @name } validation, because #{ @_msg }"

# Check that something is a model.
exports.CoreModel = new InstanceOfAssertion CoreModel, 'core-model'

# Check that something is a collection.
exports.CoreCollection = new InstanceOfAssertion CoreCollection, 'core/collection'

# Check that something is an array.
exports.Array =
  test: _.isArray
  message: (p) -> "#{ p } is not an array"

# Check that something is a function.
exports.Function =
  test: _.isFunction
  message: (p) -> "#{ p } is not a function"

# Check that something is a number
exports.Number =
  test: _.isNumber
  message: (p) -> "#{ p } is not a number"

# Check that something is a string
exports.String =
  test: _.isString
  message: (p) -> "#{ p } is not a string"

# Test if something is either null or that it passes a type-assertion.
exports.Maybe = (assertion) ->
  test: (v) -> (not v?) or (assertion.test v)
  message: (p) -> assertion.message p # If not null, then the assertion will know what is wrong.

# Test that something has a call method - (like a function).
exports.Callable =
  test: (v) -> v? and _.isFunction v.call
  message: (p) -> "#{ p } is not callable"
