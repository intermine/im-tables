{Promise} = require 'es6-promise'
_       = require 'underscore'
fs = require 'fs'

Paging = require './paging'
HasDialogues = require '../has-dialogues'
View = require '../../core-view'

# FIXME
NewFilterDialogue = require '../views/new-filter-dialogue'
# FIXME - make sure this import works
ExportDialogue = require '../views/export-dialogue'

html = fs.readFileSync __dirname + '/../../templates/page-sizer.mtpl', 'utf8'
ltd = fs.readFileSync __dirname + '/../../templates/large-table-disuader.mtpl', 'utf8'
mixOf = require '../mix-of'

EVT = 'change:size'

# This needs a test/index

# modal dialogue that presents user with range of other options instead of
# large tables, and lets them choose one.
class LargeTableDisuader extends View

  shown: false

  initialize: ->
    super

  className: 'modal im-page-size-sanity-check'

  template: _.template ltd

  hide: -> @reject 'dismiss'

  onHidden: ->
    @$el.modal 'destroy'
    @shown = false
    @remove()

  remove: ->
    return @$el.modal 'hide' if @shown # Allow removal and hiding to go together.
    @reject new Error 'unresolved before removal' # no-op if already resolved.
    delete @reject
    delete @resolve
    super

  resolve: -> # no-op, until shown.

  reject: -> # no-op, until shown.

  postRender: -> show() if @shown # In the case of (unlikely) re-rendering.

  events: ->
    'click .btn-primary': (=> @resolve 'accept')
    'click .add-filter-dialogue': (=> @resolve 'constraint')
    'click .page-backwards': (=> @resolve 'back')
    'click .page-forwards': (=> @resolve 'forward')
    'click .download-menu': (=> @resolve 'export')
    'click .close': (=> @resolve 'dismiss')
    'hidden': 'onHidden' # Can be caused by user clicking off the modal.

  # Can be called multiple times, and called on re-render.
  show: -> 
    unless @shown # If we have already done this, don't overwrite these properties
      # Create a promise and capture its resolution controls.
      @promise = new Promise (@resolve, @reject) => 
      # Following line is important - it makes the modal go away.
      @promise.then (=> @remove()), (=> @remove()) # Remove when done with.
    try
      @$el.modal().modal 'show'
      @trigger 'shown', @shown = true
    catch e
      @reject e
    return @promise

module.exports = class PageSizer extends View
  
  @include Paging
  @include HasDialogues

  tagName: 'form'
  className: "im-page-sizer form-horizontal"
  sizes: [[10], [25], [50], [100], [250]] # [0, 'All']]

  initialize: ({@query}) ->
    super
    size = @model.get 'size'
    if size? and not _.include (s for [s] in @sizes), size
      @sizes = [[size, size]].concat @sizes # assign, don't mutate
    @listenTo @model, 'change:size', (m, v) => @$('select').val v

  events: ->
    'change select': 'changePageSize'

  # TODO - make sure NewFilterDialogue supports the {@query} constructor and the show method
  # TODO - make sure ExportDialogue supports the {@query} constructor and the show method
  changePageSize: (evt) ->
    input   = @$ evt.target
    size    = parseInt input.val(), 10
    oldSize = @model.get 'size'
    accept = (=> @model.set {size})
    return accept() unless @aboveSizeThreshold() # No need for confirmation.
    pending = @whenAcceptable(size).then (action) ->
      return accept() if action is 'accept'
      input.val oldSize
      switch action
        when 'back' then @goBack 1
        when 'forward' then @goForward 1
        when 'constrain' then @openDialogue new NewFilterDialogue {@query}
        when 'export' then @openDialogue ExportDialogue {@query}
        else console.debug 'dismissed dialogue', action
    pending.then null, (e) -> console.error 'Error handling dialogues', e

  # If the new page size is potentially problematic, then check with the user
  # first, rolling back if they see sense. Otherwise, change the page size
  # without user interaction.
  # @param size the requested page size.
  # @return Promise resolved if the new size is acceptable
  whenAcceptable: (size) -> @openDialogue new LargeTableDisuader model: {size}

  template: _.template html

  getData: -> _.extend @model.toJSON(), {@sizes}

  pageSizeFeasibilityThreshold: 250

  # Check if the given size could be considered problematic
  #
  # A size if problematic if it is above the preset threshold, or if it 
  # is a request for all results, and we know that the count is large.
  # @param size The size to assess.
  aboveSizeThreshold: (size) ->
    if size and size >= @pageSizeFeasibilityThreshold
      return true
    if not size # falsy values null, 0 and '' are treated as all
      total = @model.get('count')
      return total >= @pageSizeFeasibilityThreshold
    return false


