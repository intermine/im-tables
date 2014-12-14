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
