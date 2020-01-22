should = require 'should'

{Options} = require 'imtables/options'

describe 'new Options', ->

  options = new Options

  after -> options.destroy()

  it 'should have the default values', ->

    options.get('INITIAL_SUMMARY_ROWS').should.eql 1000

describe 'Options::get (simple)', ->

  options = new Options
  after -> options.destroy()

  it 'should be able to read simple string values', ->
    options.get('StylePrefix').should.eql 'imtables'

  it 'should be able to read object values', ->
    options.get('Destinations').should.eql ['download', 'Galaxy', 'Drive', 'Dropbox']

describe 'Options::get (nested)', ->

  options = new Options
  after -> options.destroy()

  it 'should be able to read nested values (string)', ->

    options.get('Destination.Galaxy.Tool').should.eql 'flymine'

  it 'should be able to read nested values, (array)', ->

    options.get(['Destination', 'Galaxy', 'Tool']).should.eql 'flymine'
    options.get(['Destination', 'Galaxy', 'Enabled']).should.eql true

describe 'Options::set (simple)', ->

  options = new Options
  options.set Foo: 'bar'
  after -> options.destroy()

  it 'should should set values which can be read with get', ->

    options.get('Foo').should.eql 'bar'

describe 'Options::set (nested)', ->

  options = new Options
  options.set Foo: {bar: 10}
  options.set
    Destination:
      Galaxy: {Current: 'zop'}
  after -> options.destroy()

  it 'should should set values which can be read with get', ->

    options.get('Foo.bar').should.eql 10
    options.get('Destination.Galaxy.Current').should.eql 'zop'

  it 'should not have overwritten other values in the same namespace', ->

    options.get('Destination.Galaxy.Tool').should.eql 'flymine'

describe 'Options::set (keypath - Str)', ->

  options = new Options
  options.set Foo: {bar: 10}
  options.set 'Destination.Galaxy.Current', 'zop'
  after -> options.destroy()

  it 'should should set values which can be read with get', ->

    options.get('Foo.bar').should.eql 10
    options.get('Destination.Galaxy.Current').should.eql 'zop'

  it 'should not have overwritten other values in the same namespace', ->

    options.get('Destination.Galaxy.Tool').should.eql 'flymine'

describe 'Options::set (keypath - Array)', ->

  options = new Options
  options.set Foo: {bar: 10}
  options.set ['Destination', 'Galaxy', 'Current'], 'zip'
  after -> options.destroy()

  it 'should should set values which can be read with get', ->

    options.get('Foo.bar').should.eql 10
    options.get('Destination.Galaxy.Current').should.eql 'zip'

  it 'should not have overwritten other values in the same namespace', ->

    options.get('Destination.Galaxy.Tool').should.eql 'flymine'

describe 'Options change events for nested values', ->

  options = new Options
  changed = {}
  options.on 'change:Destination.Galaxy.Current', (m, v) -> changed.current = v
  options.on 'change:Destination.Galaxy.Tool', (m, v) -> changed.tool = v
  options.set
    Destination:
      Galaxy: {Current: 'zop', Tool: null}
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
  options.on 'change:Destination.Galaxy.Current', (m, v) -> changed.current = v
  options.on 'change:Destination.Galaxy', (m, v) -> changed.galaxy = v
  options.set
    Destination:
      Galaxy: null
  after -> options.destroy()

  it 'should have triggered a change event for the end key', ->
    changed.should.have.property 'galaxy'
    should.not.exist changed.galaxy

  it 'should have triggered a change event for the nested key', ->
    changed.should.have.property 'current'
    should.not.exist  changed.current

describe 'Destination Options', ->

  describe 'by default', ->

    options = new Options
    destinations = (d for d in options.get('Destinations') \
                            when options.get(['Destination', d, 'Enabled']))

    it 'should find 2 enabled destinations', ->
      destinations.length.should.eql 2

  describe 'disabling one of them', ->

    options = new Options
    options.set 'Destination.Galaxy.Enabled', false
    destinations = (d for d in options.get('Destinations') \
                            when options.get(['Destination', d, 'Enabled']))

    it 'should find 1 enabled destinations', ->
      destinations.length.should.eql 1

