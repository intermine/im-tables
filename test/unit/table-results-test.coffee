should = require 'should'
{range} = require 'underscore'

{ResultCache} = require 'imtables/utils/table-results'
Page = require 'imtables/models/page'
{Promise} = require 'es6-promise'

# This is a sufficient mock object for a ResultCache.
# All it does is count the number of requests made.
class FakeQuery

  constructor: ->
    @requests = 0

  clone: -> @

  # Return an array of numbers from start to size.
  tableRows: ({start, size}) ->
    @requests++
    Promise.resolve [start .. size]

legalInputs = [] # A large number of legal pages.
for start in (range 0, 100, 10)
  legalInputs.push new Page(start, null)
  for size in [0 .. 200]
    legalInputs.push new Page(start, size)

describe 'ResultCache', ->

  describe 'contains', ->

    describe 'on a new cache', ->

      cache = new ResultCache(new FakeQuery)

      describe 'for all legal inputs', ->

        it 'should return false', ->
          for p in legalInputs
            cache.contains(p).should.eql false, "#{ cache } contains #{ p }"

    describe 'on a cache with some results in it - no offset', ->

      cache = new ResultCache(new FakeQuery)
      cache.rows = [0 .. 99]

      describe 'for all legal inputs contained within', ->

        contained = [
          new Page(0, 100),
          new Page(1, 99),
          new Page(25, 50),
          new Page(99, 1),
          new Page(75, 25)
        ]

        it 'should return true', ->
          for p in contained
            cache.contains(p).should.eql true, "#{ cache } does not contain #{ p }"

      describe 'for all legal inputs not contained within', ->

        notContained = [
          new Page(0),
          new Page(99, 2),
          new Page(100, 1),
          new Page(1, 101),
          new Page(1, 100),
          new Page(50, 100),
          new Page(200, 100)
        ]

        it "should return false", ->
          for p in notContained
            cache.contains(p).should.eql false, "#{ cache } contains #{ p }"

    describe 'on cache with some results in it - offset 25', ->

      cache = new ResultCache(new FakeQuery)
      cache.rows = [25 .. 99]
      cache.offset = 25

      describe 'for all legal inputs contained within', ->

        contained = [
          new Page(25, 75),
          new Page(26, 74),
          new Page(25, 74),
          new Page(99, 1),
          new Page(98, 2),
          new Page(75, 25)
        ]

        it 'should return true', ->
          for p in contained
            cache.contains(p).should.eql true, "#{ cache } does not contain #{ p }"

      describe 'for all legal inputs not contained within', ->

        notContained = [
          new Page(0),
          new Page(25),
          new Page(26),
          new Page(99, 2),
          new Page(100, 1),
          new Page(25, 76),
          new Page(26, 75),
          new Page(50, 100),
          new Page(200, 100)
        ]

        it "should return false", ->
          for p in notContained
            cache.contains(p).should.eql false, "#{ cache } contains #{ p }"
