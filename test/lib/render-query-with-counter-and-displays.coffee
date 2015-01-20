Counter = require './counter.coffee'
MD = require './model-display.coffee'

module.exports = (create, afterRender = (->), props = ['model', 'state']) -> (h2, div, query) ->
  counter = new Counter el: h2, query: query
  view = create query

  counter.render()
  MD.displayModels view, props, false
  view.$el.appendTo div
  view.render()
  afterRender view

