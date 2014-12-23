Backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'

CoreModel = require './core-model'
Messages = require './messages'
Icons = require './icons'

# private incrementing id counter for children
kid = 0

getKid = -> kid++

# Class defining the core conventions of views in the application
#  - adds a data -> template -> render flow
#  - adds @make helper
#  - ensures @children, and their clean up (requires super call in initialize) 
#  - ensures @model :: CoreModel (requires super call in initialize)
#  - ensures the render cycle is established (preRender, postRender)
#  - starts listening to the RERENDER_EVENT if defined.
module.exports = class CoreView extends Backbone.View

  @include = (mixin) -> _.extend @.prototype, mixin

  initialize: ->
    @children = {}
    Model = (@Model or CoreModel)
    unless @model?
      @model = new Model
    unless @model.toJSON?
      @model = new Model @model
    @state = new CoreModel # state is *not* model; cannot be passed in. *private* to instance.
    if @RERENDER_EVENT?
      @listenTo @model, @RERENDER_EVENT, @reRender

    @on 'rendering', @preRender
    @on 'rendered', @postRender

  renderError: (resp) -> renderError(@el) resp

  # By default, the model extended with Messages and Icons
  getData: -> _.extend {Messages, Icons}, @model.toJSON()

  # Like render, but only happens if already rendered at least once.
  reRender: ->
    @render() if @rendered
    this

  # Default post-render hook. Override to hook into render-cycle
  postRender: ->

  # Default pre-render hook. Override to hook into render-cycle
  preRender: ->

  # Safely remove all existing children, apply template if
  # available, and mark as rendered. Most Views will not need
  # to override this method - instead customise getData, template
  # and/or preRender and postRender
  render: ->
    @trigger 'rendering', @rendered
    @removeAllChildren()
    if @template?
      @$el.html @template @getData()
    @trigger 'rendered', @rendered = true

    return this

  # Renders a child, appending it to part of this view.
  # Should happen after the main view is rendered.
  # The child is saved in the @children mapping so it can be disposed of later.
  # the child may be null, in which case it will be ignored.
  # A name really ought to be supplied, but one will be generated if needed.
  # If no container is given, the child is appended to the element of this view.
  renderChild: (name, view, container = @el, append = true) ->
    return this unless view?
    name ?= getKid()
    @removeChild name
    @children[name] = view
    if append
      view.$el.appendTo container
    else
      view.setElement(container[0] or container)
    view.render()
    this

  # Render a child and rather than appending it set the given element
  # as the element of the component.
  renderChildAt: (name, view, element) ->
    @renderChild name, view, element, false

  # Remove a child by name, if it exists.
  removeChild: (name) ->
    @children[name]?.remove()
    delete @children[name]

  removeAllChildren: ->
    if @children? # Might have been unset.
      for child in _.keys(@children)
        @removeChild child

  remove: ->
    @$el.parent().trigger 'childremoved', @ # Tell parents we are leaving.
    @stopListening()
    @removeAllChildren()
    @off()
    if @state?
      @state.destroy() # not likely necessary, but get rid of it in any case
      delete @state
    super
    this

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
