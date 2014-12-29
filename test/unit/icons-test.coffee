should = require 'should'

{Icons, registerIconSet} = require 'imtables/icons'
{Options} = require 'imtables/options'

ensureDestroyed = (delenda...) -> after ->
  for d in delenda
    d?.destroy

describe 'Default icons', ->

  icons = new Icons
  ensureDestroyed icons

  it 'should be able to create the HTML for an icon', ->

    icons.icon('Check').should.eql '<i class="fa fa-toggle-on"></i>'

describe 'Different icon set', ->

  options = new Options
  options.set 'icons', 'glyphicons'
  icons = new Icons options
  ensureDestroyed options, icons

  it 'should be able to create the HTML for an icon', ->

    icons.icon('Check').should.eql '<i class="glyphicon glyphicon-ok"></i>'

describe 'Custom icon set', ->

  options = new Options
  options.set 'icons', 'custom'
  registerIconSet 'custom', Base: 'custom-icons', Check: 'checked'
  icons = new Icons options
  ensureDestroyed options, icons

  it 'should be able to create the HTML for an icon', ->

    icons.icon('Check').should.eql '<i class="custom-icons checked"></i>'

describe 'Changing icon set', ->

  options = new Options
  registerIconSet 'custom', Base: 'custom-icons', Check: 'checked'
  icons = new Icons options
  options.set 'icons', 'custom' # changed after creation
  ensureDestroyed options, icons

  it 'should be able to create the HTML for an icon', ->

    icons.icon('Check').should.eql '<i class="custom-icons checked"></i>'
