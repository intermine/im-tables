Options = require 'imtables/options'
Counter = require './counter.coffee'
MD = require './model-display.coffee'

PROPS = ['model', 'state']
NOOP = ->

module.exports = (create, after = NOOP, props = PROPS) -> (h2, div, query) ->
  counter = new Counter el: h2, query: query
  view = create query, counter

  counter.render()
  MD.displayModels view, props, Options.get('ModelDisplay.Initially.Closed')
  view.$el.appendTo div
  view.render()
  after view

