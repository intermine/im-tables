Promise = require 'es6-promise'
_       = require 'underscore'

Paging = require './paging'
View = require '../core-view'
LargeTableDisuader = require '../templates/large-table-disuader'

NewFilterDialogue = require '../views/new-filter-dialogue'
# FIXME - make sure this import works
ExportDialogue = require '../views/export-dialogue'

EVT = 'change:size'

module.exports = class PageSizer extends View

  tagName: 'form'
  className: "im-page-sizer form-horizontal"
  sizes: [[10], [25], [50], [100], [250]] # [0, 'All']]

  initialize: ->
    _.extend @, Paging
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

  template: _.template """
    <label>
      <span class="hidden-tablet">Rows per page:</span>
      <select class="span1" title="Rows per page">
        <% sizes.forEach(function (s) { %>
          <option value="<%= s[0] %>" <%= (s[0] === size) && 'selected' %>>
            <%= s[1] || s[0] %>
          </option>
        <% }); %>
      </select>
    </label>
  """

  getData: -> _.extend @model.toJSON(), {@sizes}

  render: ->
    frag = $ document.createDocumentFragment()
    size = @model.get 'size'
    frag.append @template @getData()
    @$el.html frag

    this

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
  whenAcceptable: (size) -> new Promise (resolve, reject) =>
    return resolve unless @aboveSizeThreshold size

    $really = $ LargeTableDisuader {size}
    $really.find('.btn-primary').click resolve
    $really.find('.im-alternative-action').click reject
    $really.find('.btn').click -> $really.modal 'hide'
    $really.on 'hidden', ->
      $really.remove()
      reject() # if not explicitly done so.
    $really.appendTo(@el).modal().modal('show')

  addFilterDialogue: ->
    @openDialogue NewFilterDialogue

  @openDialogue: (Dialogue) ->
    dialogue = new Dialogue {@query}
    @$el.append dialogue.el
    dialogue.render()
    dialogue.show()

  # TODO - make sure ExportDialogue supports the {@query} constructor
  openDownloadMenu: -> @openDialogue ExportDialogue
