should = require 'should'
{Service} = require 'imjs'
Backbone = require 'backbone'

Formatting = require 'imtables/formatting'

URL = (process.env.TESTMODEL_URL ? 'http://localhost:8080/intermine-demo')

describe 'formatting', ->

  conn = Service.connect root: URL

  describe 'Without any formatters registered', ->

    describe 'shouldFormat(Department.name)', ->

      getPath = conn.fetchModel().then (m) -> m.makePath 'Department.name'

      it 'should return false', -> getPath.then (path) ->
        Formatting.shouldFormat(path).should.be.false

    describe 'shouldFormat(Department.employees.name)', ->

      getPath = conn.fetchModel().then (m) -> m.makePath 'Department.employees.name'

      it 'should return false', -> getPath.then (path) ->
        Formatting.shouldFormat(path).should.be.false

  describe 'with formatters registered', ->

    fakeFormatter = -> 'FOO'
    before -> Formatting.registerFormatter fakeFormatter, 'testmodel', 'Employee'
    before -> Formatting.registerFormatter (-> 'AWESOME'), 'testmodel', 'Unicorn'
    after -> Formatting.reset()

    describe 'shouldFormat(Department.name)', ->

      getPath = conn.fetchModel().then (m) -> m.makePath 'Department.name'

      it 'should return false', -> getPath.then (path) ->
        Formatting.shouldFormat(path).should.be.false

    describe 'Department.employees.name', ->

      getPath = conn.fetchModel().then (m) -> m.makePath 'Department.employees.name'

      it 'should need formatting', -> getPath.then (path) ->
        Formatting.shouldFormat(path).should.be.true

      it 'should be associated with our formatter', -> getPath.then (path) ->
        Formatting.getFormatter(path).should.eql fakeFormatter

