{Promise} = require 'es6-promise'
_       = require 'underscore'
fs = require 'fs'

Paging = require './paging'
View = require '../core-view'

NewFilterDialogue = require '../views/new-filter-dialogue'
# FIXME - make sure this import works
ExportDialogue = require '../views/export-dialogue'

html = fs.readFileSync __dirname + '/../templates/page-sizer.mtpl', 'utf8'
ltd = fs.readFileSync __dirname + '/../templates/large-table-disuader.mtpl', 'utf8'
mixOf = require '../mix-of'

EVT = 'change:size'

# This needs a test/index

class LargeTableDisuader extends View

  className: 'modal im-page-size-sanity-check'

  template: _.template ltd

module.exports = class PageSizer extends mixOf View, Paging

  tagName: 'form'
  className: "im-page-sizer form-horizontal"
  sizes: [[10], [25], [50], [100], [250]] # [0, 'All']]

  initialize: ->
    super
    size = @model.get 'size'
    if size? and not _.include (s for [s] in @sizes), size
      @sizes = [[size, size]].concat @sizes # assign, don't mutate
    @listenTo @model, 'change:size', (m, v) => @$('select').val v

  events: ->
    'change select': 'changePageSize'
    'click .add-filter-dialogue': 'addFilterDialogue'
    'click .page-forwards': 'pageForwards'
    'click .page-backwards': 'pageBackwards'
    'click .download-menu': 'openDownloadMenu'

  pageForwards: -> @goForward 1

  pageBackwards: -> @goBack 1

  changePageSize: (evt) ->
    input   = @$ evt.target # TODO - this may not work, use $ if not.
    size    = parseInt input.val(), 10
    oldSize = @model.get 'size'
    applyChange = => @model.set {size}
    rollback    = -> input.val oldSize
    @whenAcceptable(size).then applyChange, rollback

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

  # If the new page size is potentially problematic, then check with the user
  # first, rolling back if they see sense. Otherwise, change the page size
  # without user interaction.
  # @param size the requested page size.
  # @return Promise resolved if the new size is acceptable
  whenAcceptable: (size) ->
    return resolve unless @aboveSizeThreshold size

    # FIXME - use the LargeTableDisuader child view from above.
    disuader = new LargeTableDisuader model: {size}
    # All this should go in the class itself.
    $really = $ LargeTableDisuader {size}
    $really.find('.btn-primary').click resolve
    $really.find('.im-alternative-action').click reject
    $really.find('.btn').click -> $really.modal 'hide'
    $really.on 'hidden', ->
      $really.remove()
      reject() # if not explicitly done so.
    $really.appendTo(@el).modal().modal('show')

    @renderChild 'disuader', disuader
    return disuader.show() # make this return a promise for the action to take.

  addFilterDialogue: ->
    @openDialogue NewFilterDialogue

  @openDialogue: (Dialogue) ->
    dialogue = new Dialogue {@query}
    @$el.append dialogue.el
    dialogue.render()
    dialogue.show()

  # TODO - make sure ExportDialogue supports the {@query} constructor
  openDownloadMenu: -> @openDialogue ExportDialogue
