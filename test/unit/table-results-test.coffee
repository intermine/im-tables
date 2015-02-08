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
    Promise.resolve [start .. (start + size - 1)]

legalInputs = [] # A large number of legal pages.
for start in (range 0, 100, 10)
  legalInputs.push new Page(start, null)
  for size in (range 0, 1000, 25)
    legalInputs.push new Page(start, size)

describe 'ResultCache', ->

  describe 'getRequestPage', ->

    describe 'on a new cache', ->

      cache = new ResultCache(new FakeQuery)

      describe 'bounded from the beginning', ->

        inPage = new Page 0, 10
        outPage = cache.getRequestPage inPage
        expected = new Page 0, 100

        it "should be #{ expected }", ->
          outPage.should.eql expected

      describe 'bounded from the middle', ->

        inPage = new Page 10, 10
        outPage = cache.getRequestPage inPage
        expected = new Page 10, 100

        it "should be #{ expected }", ->
          outPage.should.eql expected

      describe 'unbounded from the beginning', ->

        inPage = new Page 0
        outPage = cache.getRequestPage inPage
        expected = new Page 0

        it "should be #{ expected }", ->
          outPage.should.eql expected

    describe 'on a cache with rows', ->

      cache = new ResultCache(new FakeQuery)

      beforeEach ->
        cache.rows = [200 .. 204]
        cache.offset = 200

      describe 'bounded from the beginning', ->

        inPage = new Page 0, 10
        expected = new Page 0, 200

        it "should be #{ expected }", ->
          outPage = cache.getRequestPage inPage
          outPage.should.eql expected

      describe 'paging backwards', ->

        inPage = new Page 190, 10
        expected = new Page 90, 110

        it "should be #{ expected }", ->
          outPage = cache.getRequestPage inPage
          outPage.should.eql expected

      describe 'before the beginning', ->

        inPage = new Page 10, 10
        expected = new Page 0, 200

        it "should be #{ expected }", ->
          outPage = cache.getRequestPage inPage
          outPage.should.eql expected

      describe 'unbounded from the beginning', ->

        inPage = new Page 0
        expected = new Page 0

        it "should be #{ expected }", ->
          outPage = cache.getRequestPage inPage
          outPage.should.eql expected

      describe 'gap on the right', ->

        inPage = new Page 250, 10
        expected = new Page 205, 145

        it "should be #{ expected }", ->
          outPage = cache.getRequestPage inPage
          outPage.should.eql expected

      describe 'too big a gap on the right', ->

        inPage = new Page 10000, 10
        expected = new Page 10000, 100
        outPage = null
        beforeEach ->
          outPage = cache.getRequestPage inPage

        it "should be #{ expected }", ->
          outPage.should.eql expected

        it 'should have dropped the cache', ->
          should.not.exist cache.rows
          cache.offset.should.eql 0

  describe 'addRowsToCache', ->

    describe 'on a new cache', ->

      cache = new ResultCache(new FakeQuery)
      cache.addRowsToCache(new Page 10, 10)([0 .. 9])

      it 'should add all rows', ->
        cache.rows.should.eql [0 .. 9]

      it 'should have set the offset correctly', ->
        cache.offset.should.eql 10

    describe 'on a cache with stuff in it', ->

      describe 'attempting to add a non-contiguous section', ->

        cache = new ResultCache(new FakeQuery)

        beforeEach ->
          cache.rows = [10 .. 19]
          cache.offset = 10

        it 'should throw an error on append', ->
          (-> cache.addRowsToCache(new Page 21, 1)([100])).should.throw /contig/

        it 'should be ok to add at the end', ->
          cache.addRowsToCache(new Page 20, 1)([100])
          cache.rows.should.eql [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 100]

        it 'should throw an error on prepend', ->
          (-> cache.addRowsToCache(new Page 8, 1)(['foo'])).should.throw /contig/

        it 'should be ok to add at the beginning', ->
          cache.addRowsToCache(new Page 9, 1)([100])
          cache.rows.should.eql [100, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]

      describe 'left overlap current cache', ->

        cache = new ResultCache(new FakeQuery)
        cache.rows = [10 .. 14]
        cache.offset = 10
        cache.addRowsToCache(new Page 8, 4) ['a', 'b', 'c', 'd']

        it 'should have added to the cache', ->
          cache.rows.should.eql ['a', 'b', 'c', 'd', 12, 13, 14] 

        it 'should have changed the offset', ->
          cache.offset.should.eql 8

      describe 'right overlap current cache', ->

        cache = new ResultCache(new FakeQuery)
        cache.rows = [10 .. 14]
        cache.offset = 10
        cache.addRowsToCache(new Page 13, 4) ['a', 'b', 'c', 'd']

        it 'should have added to the cache', ->
          cache.rows.should.eql [10, 11, 12, 'a', 'b', 'c', 'd']

        it 'should not have changed the offset', ->
          cache.offset.should.eql 10

      describe 'after current cache', ->

        cache = new ResultCache(new FakeQuery)
        cache.rows = [10 .. 19]
        cache.offset = 10
        cache.addRowsToCache(new Page 20, 10)([20 .. 29])

        it 'should have appended to the cache', ->
          cache.rows.should.eql [10 .. 29]

        it 'should have not changed the offset', ->
          cache.offset.should.eql 10

      describe 'building a cache from appends', ->

        cache = new ResultCache(new FakeQuery)
        cache.addRowsToCache(new Page(0, 4))("this".split '')
        cache.addRowsToCache(new Page(4, 3))(" is".split '')
        cache.addRowsToCache(new Page(7, 2))(" a".split '')
        cache.addRowsToCache(new Page(9, 6))(" cache".split '')

        it 'should have built up the right cache', ->
          cache.rows.join('').should.eql 'this is a cache'

      describe 'before current cache', ->

        cache = new ResultCache(new FakeQuery)
        cache.rows = [10 .. 19]
        cache.offset = 10
        cache.addRowsToCache(new Page 5, 5)([5, 6, 7, 8, 9])

        it 'should have prepended to the cache', ->
          cache.rows.should.eql [5 .. 19]

        it 'should have changed the offset', ->
          cache.offset.should.eql 5

      describe 'overlapping current cache', ->

        cache = new ResultCache(new FakeQuery)
        cache.rows = [10 .. 19]
        cache.offset = 10
        cache.addRowsToCache(new Page 5, 20)([5 .. 24])

        it 'should have appended and prepended to the cache', ->
          cache.rows.should.eql [5 .. 24]

        it 'should have changed the offset', ->
          cache.offset.should.eql 5

  describe 'getRows', ->

    describe 'on a new cache', ->

      cache = new ResultCache(new FakeQuery)

      describe 'for all legal inputs', ->

        it 'should throw', ->
          for p in legalInputs
            (-> cache.getRows p).should.throw 'Cache has not been updated'

    describe 'on a populated cache', ->

      describe 'with no offset', ->

        cache = new ResultCache(new FakeQuery)
        cache.rows = [0 .. 24]

        it 'should be able to get all rows', ->
          cache.getRows(new Page 0, 25).should.eql [0 .. 24]

        it 'shoud be able to get some rows', ->
          cache.getRows(new Page 10, 5).should.eql [10, 11, 12, 13, 14]

        it 'requesting a section beyond the end should be truncated', ->
          cache.getRows(new Page 20, 10).should.eql [20, 21, 22, 23, 24]

        it 'altering the results should not alter the cache', ->
          rows = cache.getRows new Page 0, 25
          rows[0] = 'foo'
          cache.rows[0].should.eql 0

      describe  'with an offset', ->

        cache = new ResultCache(new FakeQuery)
        cache.rows = [20 .. 39]
        cache.offset = 20

        it 'should be able to get all rows', ->
          cache.getRows(new Page 20, 20).should.eql [20 .. 39]

        it 'shoud be able to get some rows', ->
          cache.getRows(new Page 25, 5).should.eql [25, 26, 27, 28, 29]
          cache.getRows(new Page 20, 10).should.eql [20 .. 29]

        it 'requesting a section beyond the end should be truncated', ->
          cache.getRows(new Page 35, 10).should.eql [35, 36, 37, 38, 39]

        it 'altering the results should not alter the cache', ->
          rows = cache.getRows new Page 20, 10
          rows[0] = 'foo'
          cache.rows[0].should.eql 20

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
