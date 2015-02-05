_ = require 'underscore'
Backbone = require 'backbone'

CoreModel = require '../core-model'
CoreCollection = require './collection'

exports.assertMatch = (assertion, value, paramName = 'value') ->
  isOk = assertion.test value
  unless isOk
    throw new Error assertion.message paramName

class InstanceOfAssertion

  constructor: (@type, @name) ->
    unless @ instanceof InstanceOfAssertion # Allow construction without `new`
      return new InstanceOfAssertion @type, @name 

  test: (m) -> m instanceof @type

  message: (p) -> "#{ p } is not an instance of #{ @name }"

# Arbitrarily nested type assertions.
class StructuralTypeAssertion

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

exports.InstanceOf = InstanceOfAssertion

exports.StructuralTypeAssertion = StructuralTypeAssertion

# Check that something is a model.
exports.Model = new InstanceOfAssertion Backbone.Model, 'Backbone.Model'

# Check that something is a core-model.
exports.CoreModel = new InstanceOfAssertion CoreModel, 'core-model'

# Check that something is a collection.
exports.CoreCollection = new InstanceOfAssertion CoreCollection, 'core/collection'

# Check that something is an array.
exports.Array = IsArray =
  name: 'array'
  test: _.isArray
  message: (p) -> "#{ p } is not an array"

exports.ArrayOf = ArrayOf = (elem) ->
  name: "array of #{ elem.name }"
  test: (v) -> @passed = (IsArray.test v) and (_.all v, elem.test)
  message: (p) ->
    "#{ p } is not an array of #{ elem.name ? 'the correct type' }"

# Check that something is a function.
exports.Function =
  name: 'function'
  test: _.isFunction
  message: (p) -> "#{ p } is not a function"

# Check that something is a number
exports.Number =
  name: 'number'
  test: _.isNumber
  message: (p) -> "#{ p } is not a number"

# Check that something is a string
exports.String = StringType =
  name: 'string'
  test: _.isString
  message: (p) -> "#{ p } is not a string"

# Test if something is either null or that it passes a type-assertion.
exports.Maybe = (assertion) ->
  name: "maybe #{ assertion.name }"
  test: (v) -> (not v?) or (assertion.test v)
  message: (p) -> assertion.message p # If not null, then the assertion will know what is wrong.

# Test that something has a call method - (like a function).
exports.Callable = Callable =
  name: 'callable'
  test: (v) -> v? and _.isFunction v.call
  message: (p) -> "#{ p } is not callable"

exports.HasProperty = (prop) ->
  name: "has-property(#{ prop })"
  test: (v) -> v? and prop of v
  message: (p) -> "#{ p }.#{ prop } not found"

# If this module gets published, the stuff below should stay with
# this repo.

# A structural type for detecting queries.
# This is a structural type and not an instance-of type
# because this library will support external provision
# of queries (possibly constructed with different classes)
# and it would be good to support mocking more easily too.
#
# The selected properties do not represent the full public
# API of these classes, but they should be more than enough to
# positively identify instances of them with a very low chance
# of false positives, and zero false negatives.

exports.Service = InterMineService = new StructuralTypeAssertion 'Service',
  root: StringType
  query: Callable
  fetchModel: Callable
  fetchLists: Callable
  count: Callable
  whoami: Callable

exports.DataModel = DataModel = new StructuralTypeAssertion 'imjs.Model',
  name: StringType
  makePath: Callable
  findCommonType: Callable

exports.Query = new StructuralTypeAssertion 'Query',
  service: InterMineService
  model: DataModel
  rows: Callable
  count: Callable
  toXML: Callable
  root: StringType
  views: (ArrayOf StringType)

