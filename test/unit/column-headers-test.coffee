should = require 'should'
{Service} = require 'imjs'
Backbone = require 'backbone'

ColumnHeaders = require 'imtables/models/column-headers'

URL = (process.env.TESTMODEL_URL ? 'http://localhost:8080/intermine-demo')

emptyBlackList = new Backbone.Collection

setHeaders = (headers) -> (query) -> headers.setHeaders query, emptyBlackList

get = (attr) -> (model) -> model.get attr

depEmpNameAndAge = ['Department.employees.name', 'Department.employees.age']

describe 'models/column-headers', ->

  conn = Service.connect root: URL
  setup = (query, headers) -> -> conn.query(query).then setHeaders headers

  describe 'when the query is fully inner joined, the headers', ->

    headers = new ColumnHeaders
    inner =
      select: ['name', 'company.name', 'employees.name', 'employees.age']
      from: 'Department'

    before setup inner, headers

    it 'should contain 4 headers', ->
      headers.length.should.equal 4

    it 'should have one column for each view', ->
      headers.map(get 'path').should.eql ("Department.#{ v }" for v in inner.select)

  describe 'when the query has an outer joined reference, the headers', ->

    headers = new ColumnHeaders
    outerRef =
      select: ['name', 'company.name', 'employees.name', 'employees.age']
      from: 'Department'
      joins: ['company']

    before setup outerRef, headers

    it 'should contain 4 headers', ->
      headers.length.should.equal 4

    it 'should have one column for each view', ->
      headers.map(get 'path').should.eql ("Department.#{ v }" for v in outerRef.select)

  describe 'when the query has a single contiguous outer joined collection group', ->

    headers = new ColumnHeaders
    outerColl =
      select: ['name', 'company.name', 'employees.name', 'employees.age']
      from: 'Department'
      joins: ['employees']

    before setup outerColl, headers

    it 'should contain 3 headers', ->
      headers.length.should.equal 3

    it 'The columns should hae the join group replacing the joined columns', ->
      exp = ['Department.name', 'Department.company.name', 'Department.employees']
      headers.map(get 'path').should.eql exp

    describe 'the last column', ->

      it 'should have a sub-view', ->
        headers.last().get('replaces').should.have.lengthOf 2

      describe ', and its subview', ->

        it 'should replace the two outer-joined columns', ->
          headers.last().get('replaces').map(String).should.eql depEmpNameAndAge

        it 'should include the two outer-joined columns', ->
          headers.last().get('subview').map(String).should.eql depEmpNameAndAge

  describe 'when the query has a single discontiguous outer joined collection group, the headers', ->

    headers = new ColumnHeaders
    discontig =
      select: ['name', 'employees.name', 'company.name', 'employees.age']
      from: 'Department'
      joins: ['employees']

    before setup discontig, headers

    it 'should contain 3 headers', ->
      headers.length.should.equal 3

    it 'The columns should hae the join group replacing the joined columns', ->
      exp = ['Department.name', 'Department.employees', 'Department.company.name']
      headers.map(get 'path').should.eql exp

    describe 'the outer-joined column', ->

      it 'should replace the two outer-joined columns', ->
        headers.at(1).get('replaces').map(String).should.eql depEmpNameAndAge

      it 'should include the two outer-joined columns', ->
        headers.at(1).get('subview').map(String).should.eql depEmpNameAndAge

  describe 'when there are multiple outer joined collection groups, the headers', ->

    headers = new ColumnHeaders
    query =
      select: ['name', 'bank.name', 'departments.name', 'departments.employees.name', 'secretarys.name']
      from: 'Company'
      joins: ['departments', 'secretarys']

    before setup query, headers

    it 'should have four columns', ->
      headers.length.should.equal 4

    it 'should have two outer-joined groups', ->
      headers.filter((m) -> m.get('replaces').length).should.have.lengthOf 2

    it 'should have one group lifted to its column, and the other not', ->
      exp = [
        'Company.name',
        'Company.bank.name',
        'Company.departments',
        'Company.secretarys.name',
      ]
      headers.map(get 'path').should.eql exp

    it 'column 2 should have a view of [departments.name, departments.employees.name]', ->
      exp =  ['Company.departments.name', 'Company.departments.employees.name']
      headers.at(2).get('subview').map(String).should.eql exp

    it 'column 3 should have a view of [secretarys.name]', ->
      headers.at(3).get('subview').map(String).should.eql ['Company.secretarys.name']

  describe 'when there are multiple singleton outer joined collection groups, the headers', ->

    headers = new ColumnHeaders
    query =
      select: ['name', 'bank.name', 'departments.name', 'secretarys.name']
      from: 'Company'
      joins: ['departments', 'secretarys']

    before setup query, headers

    it 'should be the same as the view', ->
      exp = [
        'Company.name',
        'Company.bank.name',
        'Company.departments.name',
        'Company.secretarys.name',
      ]
      headers.map(get 'path').should.eql exp

  describe 'when there are multiple singleton outer joined collection groups of varying depths, the headers', ->

    headers = new ColumnHeaders
    query =
      select: ['name', 'bank.name', 'departments.employees.name', 'secretarys.name']
      from: 'Company'
      joins: ['departments', 'secretarys']

    before setup query, headers

    it 'should be the same as the view', ->
      exp = [
        'Company.name',
        'Company.bank.name',
        'Company.departments.employees.name',
        'Company.secretarys.name',
      ]
      headers.map(get 'path').should.eql exp

  describe 'when there is a single outerjoin group within an inner join group', ->

    describe ', the headers', ->

      headers = new ColumnHeaders
      query =
        select: [
          'name',
          'bank.name',
          'departments.name',
          'departments.employees.name',
          'departments.employees.age',
          'departments.employees.end',
        ]
        from: 'Company'
        joins: ['departments.employees']

      before setup query, headers

      it 'should have 4 columns', ->
        headers.length.should.equal 4

      it 'should have the one group', ->
        exp = [
          'Company.name',
          'Company.bank.name',
          'Company.departments.name',
          'Company.departments.employees',
        ]
        headers.map(get 'path').should.eql exp

      describe 'the last column', ->

        it 'should replace the outer joined group', ->
          exp = ("Company.departments.employees.#{ f }" for f in ['name', 'age', 'end'])
          headers.last().get('replaces').map(String).should.eql exp

  describe 'when the query has nested outer join groups, the headers', ->

    headers = new ColumnHeaders
    query =
      select: [
        'name',
        'bank.name',
        'departments.name',
        'departments.employees.name',
        'departments.employees.age',
      ]
      from: 'Company'
      joins: ['departments', 'departments.employees']

    before setup query, headers

    it 'should have 3 columns', ->
      headers.length.should.equal 3

    it 'should have the correct column paths', ->
      exp = ['Company.name', 'Company.bank.name', 'Company.departments']
      headers.map(get 'path').should.eql exp

    describe 'the last column', ->

      it 'should itself have have a sub-group', ->
        exp = ['Company.departments.name', 'Company.departments.employees']
        headers.last().get('subview').map(String).should.eql exp

      it 'should replace everything in its outer-join group', ->
        exp = [
          'Company.departments.name',
          'Company.departments.employees.name',
          'Company.departments.employees.age',
        ]
        headers.last().get('replaces').map(String).should.eql exp

  describe 'when the query has nested outer join groups, nested-group-first', ->

    query =
      select: [
        'name',
        'bank.name',
        'departments.employees.name',
        'departments.employees.age',
        'departments.name',
      ]
      from: 'Company'
      joins: ['departments', 'departments.employees']

    describe ', the headers', ->

      headers = new ColumnHeaders
      before setup query, headers

      it 'should have 3 columns', -> headers.length.should.equal 3

      it 'should have one column group', ->
        exp = ['Company.name', 'Company.bank.name', 'Company.departments']
        headers.map(get 'path').should.eql exp

      describe 'the last column', ->

        it 'should itself have have a sub-group', ->
          exp = ['Company.departments.employees', 'Company.departments.name']
          headers.last().get('subview').map(String).should.eql exp

        it 'should replace everything in its outer-join group', ->
          exp = [
            'Company.departments.employees.name',
            'Company.departments.employees.age',
            'Company.departments.name',
          ]
          headers.last().get('replaces').map(String).should.eql exp

  describe 'when the query has nested outer join groups, some of which are references', ->

    query =
      select: [
        'name',
        'bank.name',
        'departments.name',
        'departments.manager.name',
        'departments.manager.seniority',
        'departments.employees.name',
        'departments.employees.age',
      ]
      from: 'Company'
      joins: ['departments', 'departments.manager', 'departments.employees']

    describe 'the headers', ->

      headers = new ColumnHeaders
      before setup query, headers

      it 'should have 3 columns', ->
        headers.length.should.equal 3

      it 'should have the correct column paths', ->
        exp = ['Company.name', 'Company.bank.name', 'Company.departments']
        headers.map(get 'path').should.eql exp

      describe 'the last column', ->

        subview = [
          'Company.departments.name',
          'Company.departments.manager.name',
          'Company.departments.manager.seniority',
          'Company.departments.employees',
        ]
        replaces = [
          'Company.departments.name',
          'Company.departments.manager.name',
          'Company.departments.manager.seniority',
          'Company.departments.employees.name',
          'Company.departments.employees.age'
        ]

        it 'should have a sub-view with one sub-group', ->
          headers.last().get('subview').map(String).should.eql subview

        it 'should replace everything in its outer-join group', ->
          headers.last().get('replaces').map(String).should.eql replaces
