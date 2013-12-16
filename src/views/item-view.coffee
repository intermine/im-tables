Backbone = require 'backbone'

module.export = class ItemView extends Backbone.View

  initialize: ->
    unless @model.toJSON?
      @model = new Backbone.Model @model

  renderError: (resp) -> renderError(@el) resp

  render: ->

    if @template?
      @$el.html @template @model.toJSON()
    
    @trigger 'rendered'

    this

