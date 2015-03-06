require './shim' # This loads jquery plugins and sets up Backbone
Backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'

CoreModel = require './core-model'
Messages = require './messages'
Templates = require './templates'
Icons = require './icons'
Event = require './event'

helpers = require './templates/helpers'
onChange = require './utils/on-change'

# We only need one copy of this - it is a very generic throbber.
IndeterminateProgressBar = (Templates.template 'progress-bar') doneness: 1

# private incrementing id counter for children
kid = 0

getKid = -> kid++

# Private methods.
listenToModel = -> listenToThing.call @, 'model'
listenToState = -> listenToThing.call @, 'state'
listenToCollection = -> listenToThing.call @, 'collection'
listenToThing = (thing) ->
  definitions = _.result @, "#{ thing }Events"
  return unless _.size definitions
  throw new Error("Cannot listen to #{ thing } - it is null.") unless @[thing]?
  for event, handler of definitions
    handler = if _.isFunction handler then handler else @[handler]
    throw new Error("No handler for #{thing}:#{event}") unless handler?
    @listenTo @[thing], event, handler

# Class defining the core conventions of views in the application
#  - adds a data -> template -> render flow
#  - adds @make helper
#  - ensures @children, and their clean up (requires super call in initialize) 
#  - ensures @model :: CoreModel (requires super call in initialize)
#  - ensures @state :: CoreModel (requires super call).
#  - ensures the render cycle is established (preRender, postRender)
#  - starts listening to the RERENDER_EVENT if defined.
module.exports = class CoreView extends Backbone.View

  @include = (mixin) -> _.extend @.prototype, mixin

  hasOwnModel: true # True if the model does not belong to anyone else

  # Properties of the options object which will be made available on the
  # view at @[prop]. Additionally, their presence (via non-null check)
  # will be asserted as an invariant.
  parameters: []

  # Properties of the options object which will be made available on the
  # view at @[prop]. Default values should be provided on the prototype,
  # which will then be overriden but available to other instances.
  optionalParameters: []

  # Type assertions, one for each parameter, keyed by parameter name.
  #
  # An assertion is an object with the following structure:
  #   test :: (value :: Any) -> bool
  #   message :: (name :: String) -> String
  # 
  # Types do not need to be defined for all parameters, but they will be asserted if they are.
  parameterTypes: {}

  # Implement this method to set values on the state object. Well, that is
  # the purpose at least. Called after variants have been asserted.
  initState: ->

  initialize: (opts = {}) ->
    @state = opts.state # separate to avoid override issues in parameters
    params = (_.result @, 'parameters') ? []
    optParams = (_.result @, 'optionalParameters') ? []
    # Set all required parameters.
    _.extend @, _.pick opts, params...
    # Set optional parameters if provided.
    for p in optParams when opts[p]? # Ignore if null.
      @[p] = opts[p]
    @children = {}
    Model = (@Model or CoreModel)
    @hasOwnModel = false if (@model?.toJSON?) # We did not create this model
    @model = new Model unless @model? # Make sure we have one
    @model = new Model @model unless @model.toJSON? # Lift to Model

    @state ?= new CoreModel # State holds transient and computed data.
    unless @state.toJSON?
      @state = new CoreModel @state
    if @RERENDER_EVENT?
      @listenTo @model, @RERENDER_EVENT, @reRender

    @on 'rendering', @preRender
    @on 'rendered', @postRender
    @assertInvariants()
    @initState()
    listenToModel.call @
    listenToState.call @
    listenToCollection.call @
    @listenTo Icons, @ICONS, -> @reRender() if @template
    @listenTo @model, 'destroy', -> @remove()

  ICONS: 'change' # Specialise what icons to listen to here.

  # Restricted arity version of @stopListening - just takes an object,
  # no event names or whatnot. The purpose of this is to be used in event
  # listeners listening for removal events, eg:
  #
  #   destroy: @stopListeningTo
  #
  # rather than:
  #
  #   destroy: (m) -> @stopListening m
  stopListeningTo: (obj) -> @stopListening obj

  # Declarative model event binding. Use these hooks rather than
  # binding in initialize.

  # The list of model attributes that must be present to render.
  # If not available yet,
  # the view will listen until they are.
  renderRequires: []

  # The model events that we should listen to, eg: {'change:foo': 'reRender'}
  modelEvents: {}

  # The state events that we should listen to, eg: {'change:foo': 'reRender'}
  stateEvents: {}

  # The collection events that we should listen to, eg: {'change:foo': 'reRender'}
  collectionEvents: {}

  # Sorthand for listening for one or more change events on an emitter.
  listenForChange: (emitter, handler, props...) ->
    throw new Error('No properties listed') unless props?.length # Nothing to listen for.
    @listenTo emitter, (onChange props), handler

  renderError: (resp) -> renderError(@el) resp

  # the helpers, cloned to avoid mutation by subclasses.
  helpers: -> _.extend {IndeterminateProgressBar}, helpers

  getBaseData: ->
    helpers = _.result @, 'helpers'
    labels = _.result @, 'labels'
    _.extend {state: @state.toJSON(), Messages, Icons, labels}, helpers

  # By default, the model and collection, extending state, helpers, labels, Messages and Icons
  getData: -> _.extend @getBaseData(), @model.toJSON(), collection: (@collection?.toJSON() ? [])

  # Like render, but only happens if already rendered at least once.
  reRender: ->
    @render() if (@rendered and not @removed)
    this

  # Default post-render hook. Override to hook into render-cycle
  postRender: ->

  # Default pre-render hook. Override to hook into render-cycle
  preRender: ->

  hasAll = (model, props) -> _.all props, (p) -> model.has p

  onRenderError: (e) ->
    console.error 'RENDER FAILED', @, e
    @state.set error: e

  # Safely remove all existing children, apply template if
  # available, and mark as rendered. Most Views will not need
  # to override this method - instead customise getData, template
  # and/or renderChildren, preRender and postRender
  render: ->
    return if @removed
    requiredProps = _.result @, 'renderRequires'
    if (requiredProps?.length) and (not hasAll @model, requiredProps)
      evt = onChange requiredProps
      @listenToOnce @model, evt, @render
      return this

    prerenderEvent = new Event @rendered
    @trigger 'rendering', prerenderEvent
    return this if prerenderEvent.cancelled

    @removeAllChildren()

    if @template?
      try
        @$el.html @template @getData()
      catch e
        @onRenderError e

    @renderChildren()

    @trigger 'rendered', @rendered = true

    return this

  renderChildren: -> # Implement this method to insert children during render.

  # Renders a child, appending it to part of this view.
  # Should happen after the main view is rendered.
  # The child is saved in the @children mapping so it can be disposed of later.
  # the child may be null, in which case it will be ignored.
  # A name really ought to be supplied, but one will be generated if needed.
  # If no container is given, the child is appended to the element of this view.
  renderChild: (name, view, container = @el, placement = 'append') ->
    name ?= getKid()
    @removeChild name
    @children[name] = view
    return this unless view?
    switch placement
      when 'append' then view.$el.appendTo container
      when 'prepend' then view.$el.prependTo container
      when 'at' then view.setElement(container[0] or container)
      else throw new Error "Unknown position: #{ placement }"
    view.render()
    this

  # Render a child and rather than appending it set the given element
  # as the element of the component.
  #
  # Can be called as:
  #   this.renderChildAt '.modal-body', body
  #
  renderChildAt: (name, view, element) ->
    element ?= @$ name
    @renderChild name, view, element, 'at'

  # Remove a child by name, if it exists.
  removeChild: (name) ->
    @children[name]?.remove()
    delete @children[name]

  removeAllChildren: ->
    if @children? # Might have been unset.
      for child in _.keys(@children)
        @removeChild child

  removed: false

  remove: -> unless @removed # re-entrant
    @stopListening()
    @removed = true
    @$el.parent().trigger 'childremoved', @ # Tell parents we are leaving.
    @trigger 'remove', @
    @model.destroy() if @hasOwnModel # Destroy the model if we created it.
    @removeAllChildren()
    @off()
    super # actually remove us from the DOM (see Backbone.View)
    this

  # eg: this.make('span', {className: 'foo'}, 'bar')
  make: (elemName, attrs, content) ->
    el = document.createElement(elemName)
    $el = $(el)
    if attrs?
      for name, value of attrs
        if name in ['class', 'className']
          $el.addClass(value)
        else
          $el.attr name, value
    if content?
      if _.isArray(content)
        $el.append(x) for x in content
      else
        $el.append content
    el

  # Machinery for allowing views to make assertions about their initial state.
  invariants: -> {}

  assertInvariant: (condition, message) -> throw new Error(message) unless condition

  assertInvariants: ->
    params         = (_.result @, 'parameters') ? []
    optionalParams = (_.result @, 'optionalParameters') ? []
    paramTypes     = (_.result @, 'parameterTypes') ? {}

    # Assert that we have all our required parameters.
    for p in params
      v = @[p]
      @assertInvariant v?, "Missing required option: #{ p }"

    # Assert that all our parameters (optional and required) meet their
    # expectations.
    for p in params.concat(optionalParams)
      typeAssertion = paramTypes[p]
      if typeAssertion?
        # The constract of these calls is that they are evaluated in this order, so
        # that ::message() has access to data collected during ::test() (if it wants to do
        # so. DO NOT REORDER.
        v = @[p]
        assertion = typeAssertion.test v
        message = typeAssertion.message p
        @assertInvariant assertion, message

    # Assert any other more specific invariants.
    for condition, message of @invariants()
      @assertInvariant (_.result @, condition), message
