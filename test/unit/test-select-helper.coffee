should = require 'should'

compact = (s) -> s.replace /\s\s+/g, ' '
trim = (s) -> s.replace /(^\s*|\s*$)/g, ''

describe 'The select helper', ->

  {select} = require 'imtables/templates/helpers'

  it 'should make it easier to render a select list', ->
    exp = '<select class=\"\"> <option value=\"1\" > value 1 </option> <option value=\"2\" > value 2 </option> <option value=\"3\" > value 3 </option> </select>'
    got = select ({value: i, text: "value #{ i }"} for i in [1 .. 3])
    exp.should.eql trim compact got
