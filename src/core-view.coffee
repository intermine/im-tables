Backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'

CoreModel = require './core-model'

# Class defining the core conventions of views in the application
#  - adds a data -> template -> render flow
#  - adds @make helper
#  - ensures @children, and their clean up (requires super call in initialize) 
#  - ensures @model :: CoreModel (requires super call in initialize)
module.exports = class CoreView extends Backbone.View

  initialize: ->
    @children = {}
    unless @model?
      @model = new CoreModel
    unless @model.toJSON?
      @model = new CoreModel @model

  renderError: (resp) -> renderError(@el) resp

  getData: -> @model.toJSON()

  # Like render, but only happens if already rendered at least once.
  reRender: ->
    @render() if @rendered
    this

  # Safely remove all existing children, apply template if available, and mark as rendered
  render: ->
    @removeAllChildren()
    if @template?
      @$el.html @template @getData()
    
    @trigger 'rendered', @rendered = true

    this

  renderChild: (name, view, container) ->
    container ?= @el
    @removeChild name
    @children[name] = view
    view.render()
    view.$el.appendTo container
    this

  removeChild: (name) ->
    @children[name]?.remove()
    delete @children[name]

  removeAllChildren: ->
    if @children? # Might have been unset.
      for child of @children
        child?.remove()
    @children = {}

  remove: ->
    @removeAllChildren()
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
