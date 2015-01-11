_  = require 'underscore'

Paging = require './paging'
HasDialogues = require '../has-dialogues'
View = require '../../core-view'
Templates = require '../../templates'
Events = require '../../events'

# Dialogues
NewFilterDialogue = require '../new-filter-dialogue'
# FIXME
ExportDialogue = require '../export-dialogue'
LargeTableDisuader = require './large-table-disuader'

# This needs a test/index

module.exports = class PageSizer extends View
  
  @include Paging
  @include HasDialogues

  tagName: 'form'
  className: "im-page-sizer form-inline"

  sizes: [[10], [25], [50], [100], [250]] # [0, 'All']]

  # We need the query because we will pass it on to modal dialogues we open.
  initialize: ({@query}) ->
    super
    size = @model.get 'size'
    if size? and not _.include (s for [s] in @sizes), size
      @sizes = [[size, size]].concat @sizes # assign, don't mutate
    @listenTo @model, 'change:size', (m, v) => @$('select').val v

  events: ->
    'submit': Events.suppress
    'change select': 'changePageSize'

  # TODO - make sure NewFilterDialogue supports the {@query} constructor and the show method
  # TODO - make sure ExportDialogue supports the {@query} constructor and the show method
  changePageSize: (evt) ->
    input   = @$ evt.target
    size    = parseInt input.val(), 10
    oldSize = @model.get 'size'
    accept = (=> @model.set {size})
    return accept() unless @aboveSizeThreshold size # No need for confirmation.
    pending = @whenAcceptable(size).then (action) =>
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

  template: Templates.template 'page_sizer'

  getData: ->
    count = @model.get 'count'
    sizes = (s for s in @sizes when ((not count?) or (s[0] <= count)))
    _.extend super, {sizes}

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