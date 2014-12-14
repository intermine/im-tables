should = require 'should'

{Messages} = require '../build/messages'

describe 'Messages::getText', ->

  messages = new Messages

  after -> messages.destroy()

  it 'should know about the messages', ->
    messages.get('largetable.abort').should.eql 'Cancel'

  it 'should be able to format a simple message', ->

    messages.getText('largetable.abort').should.eql 'Cancel'

  it 'should be able to format a parameterised message', ->

    expected = 'Set page size to 750'
    messages.getText('largetable.ok', size: 750).should.eql expected

describe 'Changing messages', ->

  expected = 'make 750 the page size'
  messages = new Messages
  # Pull a value into cache
  initialRendering = messages.getText('largetable.ok', size: 1000)
  messages.set
    'largetable.ok': 'make <%- size %> the page size'

  after -> messages.destroy()

  it 'should use the new template', ->
    messages.getText('largetable.ok', size: 750).should.eql expected

  it 'should not have done impossible things', ->
    initialRendering.should.not.eql expected

describe 'Precompiled template support', ->

  messages = new Messages
  messages.set squared: (x) -> "#{ x } squared is #{ x * x }"

  after -> messages.destroy()

  it 'should use the new template', ->
    messages.getText('squared', 10).should.eql "10 squared is 100"
