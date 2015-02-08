should = require 'should'

Page = require 'imtables/models/page'

describe 'Page', ->

  describe 'constructor', ->

    describe 'called with no arguments', ->

      call = -> new Page

      it 'should throw', ->
        call.should.throw /Start/

    describe 'called with one argument', ->

      page = new Page 0

      it 'should be a page for all results', ->
        page.all().should.be.true

    describe 'called with two arguments', ->

      page = new Page 10, 10

      it 'should go from 10', ->
        page.start.should.eql 10

      it 'should go to 20', ->
        page.end().should.eql 20


  describe 'Page(50 .. 60).isBefore', ->

    page = new Page 50, 10

    describe '25', ->

      it 'should be false', ->
        page.isBefore(25).should.be.false

    describe '55', ->

      it 'should be false', ->
        page.isBefore(55).should.be.false

    describe '65', ->

      it 'should be true', ->
        page.isBefore(65).should.be.true

    describe '60', ->

      it 'should be false', ->
        page.isBefore(60).should.be.false

    describe '61', ->

      it 'should be true', ->
        page.isBefore(61).should.be.true

  describe 'Page(50 .. 60).isAfter', ->

    page = new Page 50, 10

    describe '25', ->

      it 'should be true', ->
        page.isAfter(25).should.be.true

    describe '49', ->

      it 'should be true', ->
        page.isAfter(49).should.be.true

    describe '50', ->

      it 'should be false', ->
        page.isAfter(50).should.be.false

    describe '55', ->

      it 'should be false', ->
        page.isAfter(55).should.be.false

    describe '65', ->

      it 'should be false', ->
        page.isAfter(65).should.be.false

    describe '60', ->

      it 'should be false', ->
        page.isAfter(60).should.be.false

    describe '61', ->

      it 'should be false', ->
        page.isAfter(61).should.be.false

  describe 'Page(50 .. 60).leftGap', ->

    page = new Page 50, 10

    describe '25', ->

      it 'should be 25', ->
        page.leftGap(25).should.eql 25

    describe '40', ->

      it 'should be 10', ->
        page.leftGap(40).should.eql 10

    describe '49', ->

      it 'should be 1', ->
        page.leftGap(49).should.eql 1

    describe '50', ->

      it 'should not exist', ->
        should.not.exist page.leftGap 50

    describe '55', ->

      it 'should not exist', ->
        should.not.exist page.leftGap 55

    describe '65', ->

      it 'should not exist', ->
        should.not.exist page.leftGap 65

    describe '60', ->

      it 'should not exist', ->
        should.not.exist page.leftGap 60

    describe '61', ->

      it 'should not exist', ->
        should.not.exist page.leftGap 61

  describe 'Page(50 .. 60).rightGap', ->

    page = new Page 50, 10

    describe '25', ->

      it 'should not exist', ->
        should.not.exist page.rightGap 25

    describe '40', ->

      it 'should not exist', ->
        should.not.exist page.rightGap 40

    describe '49', ->

      it 'should not exist', ->
        should.not.exist page.rightGap 49

    describe '50', ->

      it 'should not exist', ->
        should.not.exist page.rightGap 50

    describe '55', ->

      it 'should not exist', ->
        should.not.exist page.rightGap 55

    describe '65', ->

      it 'should be 5', ->
        page.rightGap(65).should.eql 5

    describe '60', ->

      it 'should not exist', ->
        should.not.exist page.rightGap 60

    describe '61', ->

      it 'should be 1', ->
        page.rightGap(61).should.eql 1

    describe '75', ->

      it 'should be 15', ->
        page.rightGap(75).should.eql 15
