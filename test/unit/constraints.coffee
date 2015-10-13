should = require 'should'

Constraint = require 'imtables/models/constraint'
{Promise} = require 'es6-promise'

# This fakes enough of the imjs pathingo object to get the test to run.
class FakePathInfo
  constructor: ->

  isAttribute: ->
    false

  getType: ->
    getDisplayName: ->
      return Promise.resolve 'testResolve'

  getDisplayName: ->
    Promise.resolve 'testResolve'

#This is specifically for testing https://github.com/intermine/intermine/issues/1163. 
describe 'Constraints', ->
  it 'should understand what to do with NULL operators', ->
    constraint = new Constraint opts =
      op: 'IS NULL'
      value: "IS NULL"
      code: "A"
      path: new FakePathInfo
