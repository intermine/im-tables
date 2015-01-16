Counter = require './counter.coffee'
MD = require './model-display.coffee'

module.exports = (create, afterRender = (->)) -> (heading, container, query) ->
  counter = new Counter el: heading, query: query
  view = create query

  counter.render()
  MD.displayModels view, ['model', 'state'], false
  view.$el.appendTo container
  view.render()
  afterRender view

