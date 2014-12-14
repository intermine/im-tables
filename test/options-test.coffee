should = require 'should'

{Options} = require '../build/options'

describe 'new Options', ->

  options = new Options

  after -> options.destroy()

  it 'should have the default values', ->

    options.get('INITIAL_SUMMARY_ROWS').should.eql 1000

describe 'Options::get (nested)', ->

  options = new Options
  after -> options.destroy()

  it 'should be able to read nested values', ->

    options.get('Galaxy.Tool').should.eql 'flymine'

describe 'Options::set (simple)', ->

  options = new Options
  options.set Foo: 'bar'
  after -> options.destroy()

  it 'should should set values which can be read with get', ->

    options.get('Foo').should.eql 'bar'

describe 'Options::set (nested)', ->

  options = new Options
  options.set Foo: {bar: 10}
  options.set Galaxy: {Current: 'zop'}
  after -> options.destroy()

  it 'should should set values which can be read with get', ->

    options.get('Foo.bar').should.eql 10
    options.get('Galaxy.Current').should.eql 'zop'

  it 'should not have overwritten other values in the same namespace', ->

    options.get('Galaxy.Tool').should.eql 'flymine'

describe 'Options change events for nested values', ->

  options = new Options
  changed = {}
  options.on 'change:Galaxy.Current', (m, v) -> changed.current = v
  options.on 'change:Galaxy.Tool', (m, v) -> changed.tool = v
  options.set Galaxy: {Current: 'zop', Tool: null}
  after -> options.destroy()

  it 'should have triggered a change event for the nested key', ->
    changed.should.have.property 'current'
    changed.current.should.eql 'zop'

  it 'should have triggered a change event for the nested key', ->
    changed.should.have.property 'tool'
    should.not.exist changed.tool

describe 'Options events for unsetting previous keys', ->

  options = new Options
  changed = {}
  options.on 'change:Galaxy.Current', (m, v) -> changed.current = v
  options.set Galaxy: null
  after -> options.destroy()

  it 'should have triggered a change event for the nested key', ->
    changed.should.have.property 'current'
    should.not.exist  changed.current
