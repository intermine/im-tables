$ = require 'jquery'
fs = require 'fs'
_ = require 'underscore'

CoreView = require 'imtables/core-view'
Options = require 'imtables/options'
{Icons, names} = require 'imtables/icons'

Toggles = require '../lib/toggles'

html = fs.readFileSync __dirname + '/../templates/icons.mtpl', 'utf8'

class IconViewer extends CoreView

  Model: Icons

  template: _.template html

  getData: -> names: names(), Icons: @model

  modelEvents: -> change: @reRender

icons = new IconViewer

optionsΤοggles = new Toggles
  model: Options
  toggles: [{
    attr: 'icons',
    type: 'enum',
    opts: ['fontawesome', 'glyphicons']
  }]

$ ->
  document.body.appendChild optionsΤοggles.render().el
  document.querySelector('#demo').appendChild icons.render().el
