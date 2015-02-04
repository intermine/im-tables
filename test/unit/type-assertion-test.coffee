should = require 'should'

TypeAssertions = require 'imtables/core/type-assertions'

describe 'StructuralTypeAssertion', ->

  fooStructure = new TypeAssertions.StructuralTypeAssertion 'FooType',
    foo: TypeAssertions.Number
    bar: TypeAssertions.String
    baz: TypeAssertions.Function

  quuxStructure = new TypeAssertions.StructuralTypeAssertion 'QuuxType',
    name: TypeAssertions.String
    foo: fooStructure

  describe 'nested structure', ->

    assertion = quuxStructure

    describe 'goodObj', ->

      goodObj =
        name: 'goodun'
        foo:
          foo: 2
          bar: 'Sono una stringa'
          baz: -> 'molto originale!'

      it 'should pass the type assertion', ->
        assertion.test(goodObj).should.be.true

    describe 'badObj_1', ->

      badObj =
        name: 'badun'

      isOk = assertion.test badObj
      msg = assertion.message 'badObj'
      expMsg = [
        'badObj failed QuuxType validation,',
        'because .foo failed FooType validation,',
        'because it is null'
      ].join ' '

      it 'should not pass the type assertion', ->
        isOk.should.be.false

      it 'should report that .foo is null', ->
        msg.should.eql expMsg

    describe 'badObj_2', ->

      badObj =
        name: 'badun'
        foo: ->
          foo: 1

      isOk = assertion.test badObj
      msg = assertion.message 'badObj'
      expMsg = [
        'badObj failed QuuxType validation,',
        'because .foo failed FooType validation,',
        'because .foo is not a number'
      ].join ' '

      it 'should not pass the type assertion', ->
        isOk.should.be.false

      it 'should report that bar is wrong', ->
        msg.should.eql expMsg

  describe 'flat structure', ->

    assertion = fooStructure

    describe 'goodObj', ->

      goodObj =
        foo: 1
        bar: 'je suis une chaîne de caractères'
        baz: -> throw new Error 'BOOM'

      it 'should pass the type assertion', ->
        assertion.test(goodObj).should.be.true

    describe 'nullObj', ->

      nullObj = null

      isOk = assertion.test nullObj
      msg = assertion.message 'badObj'
      expMsg = 'badObj failed FooType validation, because it is null'

      it 'should not pass the type assertion', ->
        isOk.should.be.false

      it 'should report that the object is null', ->
        msg.should.eql expMsg

    describe 'badObj_1', ->

      badObj_1 =
        bar: 'I have no foo'
        baz: -> 'still no foo'

      isOk = assertion.test badObj_1
      msg = assertion.message 'badObj'
      expMsg = 'badObj failed FooType validation, because .foo is not a number'

      it 'should not pass the type assertion', ->
        isOk.should.be.false

      it 'should report that the object has a bad foo', ->
        msg.should.eql expMsg

    describe 'badObj_2', ->

      badObj_2 =
        foo: 'I am not a number'
        bar: 'I got that reference'
        baz: -> 'very witty.'

      isOk = assertion.test badObj_2
      msg = assertion.message 'badObj'
      expMsg = 'badObj failed FooType validation, because .foo is not a number'

      it 'should not pass the type assertion', ->
        isOk.should.be.false

      it 'should report that the object has a bad foo', ->
        msg.should.eql expMsg

    describe 'badObj_3', ->

      badObj_3 =
        foo: 100
        bar: 101
        baz: -> 'Uh oh.'

      isOk = assertion.test badObj_3
      msg = assertion.message 'badObj'
      expMsg = 'badObj failed FooType validation, because .bar is not a string'

      it 'should not pass the type assertion', ->
        isOk.should.be.false

      it 'should report that the object has a bad bar', ->
        msg.should.eql expMsg

    describe 'badObj_4', ->

      badObj_4 =
        foo: 100
        bar: 'Ich bin eine Zeichenkette'
        baz: 'Na und?'

      isOk = assertion.test badObj_4
      msg = assertion.message 'badObj'
      expMsg = 'badObj failed FooType validation, because .baz is not a function'

      it 'should not pass the type assertion', ->
        isOk.should.be.false

      it 'should report that the object has a bad baz', ->
        msg.should.eql expMsg


