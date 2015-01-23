should = require 'should'

Backbone = require 'backbone'

AvailableColumns = require 'imtables/models/available-columns'

class FakePath extends Backbone.Model

  constructor: (parts) ->
    super()
    @set id: String(parts), parts: parts, displayName: parts.join(' > ')

x       = new FakePath ['a']
x_y     = new FakePath ['a', 'b']
x_y_z   = new FakePath ['a','b', 'c']
x_y_q   = new FakePath ['a','b', 'q']
x_y_z_0 = new FakePath ['a', 'b', 'c', 'd']
x_y_z_1 = new FakePath ['a', 'b', 'c', 'e']
x_y_z_1_2 = new FakePath ['a', 'b', 'c', 'e', 'f']

describe 'AvailableColumns', ->

  describe 'comparator', ->

    available = new AvailableColumns

    it 'should sort x before x_y', ->
      available.comparator( x, x_y ).should.eql -1

  describe 'maintaining sort order', ->

    available = new AvailableColumns
    # Added out of order.
    available.add x_y
    available.add x_y_q
    available.add x_y_z
    available.add x

    it 'should have 4 models', ->
      available.size().should.eql 4

    it 'should be sorted', ->
      available.pluck 'displayName'
              .join ','
              .should.eql 'a,a > b,a > b > c,a > b > q'
