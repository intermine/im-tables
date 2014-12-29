should = require 'should'

OpenNodes = require 'imtables/models/open-nodes'

# The methods ::equals, ::isRoot and ::getParent are used by descendsFrom,
# so they need mocking, and UniqItems uses toString.
class FakePath

  constructor: (@parts) ->

  getParent: -> new FakePath @parts.slice 0, @parts.length - 1

  isRoot: -> @parts.length is 1

  equals: (other) -> @parts.join('-') is (other?.parts or []).join('-')

  toString: -> "FakePath(#{ @parts.join '.' })"

x       = new FakePath ['a']
x_y     = new FakePath ['a', 'b']
x_y_z   = new FakePath ['a','b', 'c']
x_y_q   = new FakePath ['a','b', 'q']
x_y_z_0 = new FakePath ['a', 'b', 'c', 'd']
x_y_z_1 = new FakePath ['a', 'b', 'c', 'e']
x_y_z_1_2 = new FakePath ['a', 'b', 'c', 'e', 'f']

unrelated = new FakePath [0 .. 10]
not_a_path = {}

ends = [x_y_z_0, x_y_z_1]

describe 'OpenNodes::contains', ->

  nodes = new OpenNodes ends

  it 'should contain the leaves', ->
    for end in ends
      contained = nodes.contains end
      contained.should.be.true

  it 'should contain the root', ->
    contained = nodes.contains x
    contained.should.be.true

  it 'should contain an intermediate portion', ->
    contained = nodes.contains x_y
    contained.should.be.true

  it 'should not contain unrelated paths', ->
    nodes.contains(unrelated).should.not.be.true

  it 'should not contain null', ->
    nodes.contains(null).should.not.be.true

  it 'should not contain non-paths', ->
    nodes.contains(not_a_path).should.not.be.true

  it 'should not contain uncontained leaves', ->
    nodes.contains(x_y_z_1_2).should.not.be.true

describe 'OpenNodes::remove', ->
  nodes = new OpenNodes [x_y_q, x_y_z_0, x_y_z_1]
  nodes.remove x_y_z

  it 'should not contain descendent leaves', ->
    nodes.contains(x_y_z_0).should.not.be.true

  it 'should not contain the target of removal', ->
    nodes.contains(x_y_z).should.not.be.true

  it 'should still contain the fork', ->
    nodes.contains(x_y_q).should.be.true

