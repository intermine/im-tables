should = require 'should'

Constraint = require 'imtables/models/constraint'
{PathInfo} = require 'imjs'
{Promise} = require 'es6-promise'

class FakePathInfo
  constructor: ->

  isAttribute: ->
    false

  getType: ->
    getDisplayName: ->
      return Promise.resolve 'testResolve'

  getDisplayName: ->
    Promise.resolve 'testResolve'

describe 'Constraints', ->

  it 'should understand what to do with NULL operators', ->
    constraint = new Constraint opts =
      op: 'IS NULL'
      value: "IS NULL"
      code: "A"
      path: new FakePathInfo
