Backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'

# Class defining the core conventions of views in the application
module.exports = class CoreView extends Backbone.View

  initialize: ->
    @children = {}
    unless @model?
      @model = new Backbone.Model
    unless @model.toJSON?
      @model = new Backbone.Model @model

  renderError: (resp) -> renderError(@el) resp

  getData: -> @model.toJSON()

  render: ->
    if @template?
      @$el.html @template @getData()
    
    @trigger 'rendered'

    this

  remove: ->
    if @children? # Might have been unset.
      for child of @children
        child?.remove()
    super

  make: (elemName, attrs, content) ->
    el = document.createElement(elemName)
    $el = $(el)
    if attrs?
      for name, value of attrs
        if name is 'class'
          $el.addClass(value)
        else
          $el.attr name, value
    if content?
      if _.isArray(content)
        $el.append(x) for x in content
      else
        $el.append content

    el
