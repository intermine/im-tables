should = require 'should'
{Service} = require 'imjs'

calculateRowTemplate = require 'imtables/utils/calculate-row-template'

URL = (process.env.TESTMODEL_URL ? 'http://localhost:8080/intermine-demo')

describe 'utils/calculate-row-template', ->

  conn = Service.connect root: URL

  describe 'when the query is fully inner joined', ->

    inner =
      select: ['name', 'company.name', 'employees.name', 'employees.age']
      from: 'Department'

    buildRow = conn.query(inner).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 4 somethings', -> buildRow.then (row) ->
      row.length.should.equal 4

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    it 'the columns should be the same as the view', -> buildRow.then (row) ->
      (c.column for c in row).should.eql ("Department.#{ v }" for v in inner.select)

  describe 'when the query has an outer joined reference', ->

    outerRef =
      select: ['name', 'company.name', 'employees.name', 'employees.age']
      from: 'Department'
      joins: ['company']

    buildRow = conn.query(outerRef).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 4 somethings', -> buildRow.then (row) ->
      row.length.should.equal 4

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    it 'the columns should be the same as the view', -> buildRow.then (row) ->
      (c.column for c in row).should.eql ("Department.#{ v }" for v in outerRef.select)

  describe 'when the query has a single contiguous outer joined collection group', ->

    outerRef =
      select: ['name', 'company.name', 'employees.name', 'employees.age']
      from: 'Department'
      joins: ['employees']

    buildRow = conn.query(outerRef).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 3 somethings', -> buildRow.then (row) ->
      row.length.should.equal 3

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    it 'the columns should be the same as the view', -> buildRow.then (row) ->
      exp = ['Department.name', 'Department.company.name', 'Department.employees']
      (c.column for c in row).should.eql exp

    describe 'the last column', ->

      getLastColumn = buildRow.then ([hds..., last]) -> last

      it 'should have a sub-view', -> getLastColumn.then (last) ->
        last.should.have.property 'view'

      describe 'the subview', ->

        getSubView = getLastColumn.then ({view}) -> view

        it 'should include the two outer-joined columns', -> getSubView.then (view) ->
          view.should.eql ['Department.employees.name', 'Department.employees.age']

  describe 'when the query has a single discontiguous outer joined collection group', ->

    discontig =
      select: ['name', 'employees.name', 'company.name', 'employees.age']
      from: 'Department'
      joins: ['employees']

    buildRow = conn.query(discontig).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 3 somethings', -> buildRow.then (row) ->
      row.length.should.equal 3

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    it 'should have sub-views on cell 1', -> buildRow.then ([a, b, c]) ->
      b.should.have.property 'view'

    it 'employees should appear once in the column list', -> buildRow.then (row) ->
      exp = [
        'Department.name',
        'Department.employees',
        'Department.company.name',
      ]
      (c.column for c in row).should.eql exp

    describe 'the outer-joined column', ->

      getGroupedColumn = buildRow.then ([fst, snd, thd]) -> snd

      it 'should have a sub-view', -> getGroupedColumn.then (group) ->
        group.should.have.property 'view'

      describe 'the subview', ->

        getSubView = getGroupedColumn.then ({view}) -> view

        it 'should include the two outer-joined columns', -> getSubView.then (view) ->
          view.should.eql ['Department.employees.name', 'Department.employees.age']

  describe 'when there are multiple discontiguous outer joined collection groups', ->

    query =
      select: ['name', 'bank.name', 'departments.name', 'secretarys.name']
      from: 'Company'
      joins: ['departments', 'secretarys']

    buildRow = conn.query(query).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 4 somethings', -> buildRow.then (row) ->
      row.length.should.equal 4

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    it 'should have sub-views on cells 2 and 3', -> buildRow.then ([a, b, c, d]) ->
      c.should.have.property 'view'
      d.should.have.property 'view'

    it 'The column list should have two groups', -> buildRow.then (row) ->
      exp = [
        'Company.name',
        'Company.bank.name',
        'Company.departments',
        'Company.secretarys',
      ]
      (c.column for c in row).should.eql exp

    it 'column c should have a view of [departments.name]', -> buildRow.then ([a, b, c]) ->
      c.view.should.eql ['Company.departments.name']

    it 'column d should have a view of [secretarys.name]', -> buildRow.then ([a, b, c, d]) ->
      d.view.should.eql ['Company.secretarys.name']

  describe 'when the query a single outerjoin group within an inner join group', ->

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

    buildRow = conn.query(query).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 4 somethings', -> buildRow.then (row) ->
      row.length.should.equal 4

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    it 'The column list should have the one group', -> buildRow.then (row) ->
      exp = [
        'Company.name',
        'Company.bank.name',
        'Company.departments.name',
        'Company.departments.employees',
      ]
      (c.column for c in row).should.eql exp

    describe 'the last column', ->

      getLastColumn = buildRow.then ([cols..., last]) -> last

      it 'should have a sub-view', -> getLastColumn.then (last) ->
        last.should.have.property 'view'

      describe 'and its view', ->

        getView = getLastColumn.then ({view}) -> view
        exp = ("Company.departments.employees.#{ f }" for f in ['name', 'age', 'end'])

        it 'should contain the properties of employees' , -> getView.then (view) ->
          view.should.eql exp

  describe 'when the query has nested outer join groups', ->

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

    buildRow = conn.query(query).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 3 somethings', -> buildRow.then (row) ->
      row.length.should.equal 3

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    describe 'the columns', ->

      getColumns = buildRow.then (row) -> (c.column for c in row)
      exp = ['Company.name', 'Company.bank.name', 'Company.departments']

      it 'should have the correct column paths', -> getColumns.then (cs) ->
        cs.should.eql exp

    describe 'the last column', ->

      getLastColumn = buildRow.then ([cols..., last]) -> last

      it 'should have a sub-view', -> getLastColumn.then (col) ->
        col.should.have.property 'view'

      describe 'and its view', ->

        getView = getLastColumn.then ({view}) -> view

        it 'should eql [departments.name, departments.employees]', -> getView.then (view) ->
          view.should.eql ['Company.departments.name', 'Company.departments.employees']

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

    buildRow = conn.query(query).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 3 somethings', -> buildRow.then (row) ->
      row.length.should.equal 3

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    describe 'the columns', ->

      getColumns = buildRow.then (row) -> (c.column for c in row)
      exp = ['Company.name', 'Company.bank.name', 'Company.departments']

      it 'should have the correct column paths', -> getColumns.then (cs) ->
        cs.should.eql exp

    describe 'the last column', ->

      getLastColumn = buildRow.then ([cols..., last]) -> last

      it 'should have a sub-view', -> getLastColumn.then (col) ->
        col.should.have.property 'view'

      describe 'and its view', ->

        getView = getLastColumn.then ({view}) -> view
        exp = ['Company.departments.employees', 'Company.departments.name']

        it 'should eql [departments.employees,departments.name]', -> getView.then (view) ->
          view.should.eql exp

  describe 'when the query has nested outer join groups, discontiguous declaration', ->

    query =
      select: [
        'name',
        'bank.name',
        'departments.employees.name',
        'departments.name',
        'departments.employees.age',
      ]
      from: 'Company'
      joins: ['departments', 'departments.employees']

    buildRow = conn.query(query).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 3 somethings', -> buildRow.then (row) ->
      row.length.should.equal 3

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    describe 'the columns', ->

      getColumns = buildRow.then (row) -> (c.column for c in row)
      exp = ['Company.name', 'Company.bank.name', 'Company.departments']

      it 'should have the correct column paths', -> getColumns.then (cs) ->
        cs.should.eql exp

    describe 'the last column', ->

      getLastColumn = buildRow.then ([cols..., last]) -> last

      it 'should have a sub-view', -> getLastColumn.then (col) ->
        col.should.have.property 'view'

      describe 'and its view', ->

        getView = getLastColumn.then ({view}) -> view
        exp = ['Company.departments.employees', 'Company.departments.name']

        it 'should eql [departments.employees,departments.name]', -> getView.then (view) ->
          view.should.eql exp

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

    buildRow = conn.query(query).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 3 somethings', -> buildRow.then (row) ->
      row.length.should.equal 3

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    describe 'the columns', ->

      getColumns = buildRow.then (row) -> (c.column for c in row)
      exp = ['Company.name', 'Company.bank.name', 'Company.departments']

      it 'should have the correct column paths', -> getColumns.then (cs) ->
        cs.should.eql exp

    describe 'the last column', ->

      getLastColumn = buildRow.then ([cols..., last]) -> last

      it 'should have a sub-view', -> getLastColumn.then (col) ->
        col.should.have.property 'view'

      describe 'and its view', ->

        getView = getLastColumn.then ({view}) -> view
        exp = [
          'Company.departments.name',
          'Company.departments.manager.name',
          'Company.departments.manager.seniority',
          'Company.departments.employees',
        ]

        it 'should eql should contain attrs of dep and manager, and a group for emps', ->
          getView.then (view) -> view.should.eql exp

  describe 'when the query has deeply nested outer join groups', ->

    query =
      name: 'Dashboard Query'
      select: [
        'company.name',
        'name',
        'company.contractors.name',
        'company.contractors.seniority',
        'company.contractors.businessAddress.address',
        'company.contractors.oldComs.name',
        'company.contractors.oldComs.address.address'
      ]
      from: 'Department'
      joins: [
        'Department.company.contractors.oldComs',
        'Department.company.contractors.oldComs.address',
      ]

    buildRow = conn.query(query).then calculateRowTemplate

    it 'should return something', -> buildRow.then (row) ->
      should.exist row

    it 'should return 3 somethings', -> buildRow.then (row) ->
      row.length.should.equal 6

    it 'each element should have a column attribute', -> buildRow.then (row) ->
      row.forEach (col) -> col.should.have.property 'column'

    describe 'the columns', ->

      getColumns = buildRow.then (row) -> (c.column for c in row)
      exp = [
        'Department.company.name',
        'Department.name',
        'Department.company.contractors.name',
        'Department.company.contractors.seniority',
        'Department.company.contractors.businessAddress.address',
        'Department.company.contractors.oldComs'
      ]

      it 'should have the correct column paths', -> getColumns.then (cs) ->
        cs.should.eql exp
