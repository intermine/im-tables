_ = require 'underscore'
fs = require 'fs'

AttributeValueControls = require './attribute-value-controls'

html = fs.readFileSync __dirname + '/../templates/extra-value-controls.html', 'utf8'

template = _.template html

module.exports = class LoopValueControls extends AttributeValueControls

  template: (data) ->
    base = super
    base + template data

  events: ->
    'change .im-con-value-attr': 'setValue'
    'change .im-extra-value': 'setExtraValue'

  setValue: -> @model.set value: @$('.im-con-value-attr').val()

  setExtraValue: -> @model.set extraValue: @$('.im-extra-value').val()

  provideSuggestions: -> # Easiest just to override this really.

