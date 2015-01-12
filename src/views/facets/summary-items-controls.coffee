_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

bool = (x) -> !!x

negateOps = (ops) ->
  ret = {}
  ret.multi = if ops.multi is 'ONE OF' then 'NONE OF' else 'ONE OF'
  ret.single = if ops.single is '==' then '!==' else '=='
  ret.absent = if ops.absent is 'IS NULL' then 'IS NOT NULL' else 'IS NULL'
  ret

# Null safe event ignorer, and blocker.
IGNORE = (e) -> if e?
  e.preventDefault()
  e.stopPropagation()

BASIC_OPS =
  single: '=='
  multi: 'ONE OF'
  absent: 'IS NULL'

# One day tab will be expunged, one day...
SUMMARY_FORMATS =
  tab: 'tsv'
  csv: 'csv'
  xml: 'xml'
  json: 'json'

# The minimum number of values a constraint needs to have before we will
# optimise it to its inverse to avoid very large constraints.
MIN_VALS_OPTIMISATION = 10

# These get their own view as they have a different re-render
# schedule to that of the main summary.
module.exports = class SummaryItemsControls extends CoreView

  RERENDER_EVT: 'change'

  initialize: ->
    super
    @listenTo @model.items, 'change:selected', @reRender

  # Invariants

  invariants: ->
    viewIsAttribute: "No view, or view not Attribute: #{ @view }"
    hasCollection: "No collection"

  viewIsAttribute: -> @model?.view?.isAttribute?()

  hasCollection: -> @model?.items?

  # The template, and data used by templates

  template: Templates.template 'summary_items_controls'

  getData: ->
    anyItemSelected = bool @model.items.findWhere selected: true
    _.extend super, {anyItemSelected}

  # Subviews and post-render actions.

  postRender: ->
    @activateTooltips()
    @activatePopovers()

  activateTooltips: ->
    @$btns = @$('.btn[title]').tooltip placement: 'top', container: @el

  activatePopovers: ->
    @$('.im-download').popover
      placement: 'top'
      html: true
      container: @el
      title: Messages.getText('summary.DownloadFormat')
      content: @getDownloadPopover()
      trigger: 'manual'

  downloadPopoverTemplate: Templates.template 'download_popover'

  # Returns the HTML for the download-popover.
  getDownloadPopover: -> @downloadPopoverTemplate
    query: @model.query
    path: @model.view.toString()
    formats: SUMMARY_FORMATS

  # Event definitions and their handlers.

  events: ->
    'click .im-export-summary': 'exportSummary'
    'click': 'hideTooltips'
    'click .btn-cancel': 'unsetSelection'
    'click .btn-toggle-selection': 'toggleSelection'
    'click .im-filter-group .dropdown-toggle': 'toggleDropdown'
    'click .im-download': 'toggleDownloadPopover'
    'click .im-filter-in': _.bind @addConstraint, @, BASIC_OPS
    'click .im-filter-out': _.bind @addConstraint, @, negateOps BASIC_OPS

  exportSummary: (e) ->
    # The only purpose of this is to reinstate the default <a> click behaviour which is
    # being swallowed by another click handler. This is really dumb, but for future
    # reference this is how you block someone else's click handlers.
    e.stopImmediatePropagation()
    return true

  hideTooltips: -> @$btns?.tooltip 'hide'

  unsetSelection: (e) -> @changeSelection (item) -> item.set selected: false

  toggleSelection: (e) -> @changeSelection (x) -> x.toggle 'selected' if x.get 'visible'

   # The following is due to the practice of bootstrap forcing
   # all dropdowns closed when another opens, preventing nested
   # dropdowns, which is what we have here.
  toggleDropdown: ->
    @$('.im-filter-group').toggleClass 'open'

  # Open (or close) the download popover
  toggleDownloadPopover: ->
    @$('.im-download').popover 'toggle'

  addConstraint: (ops, e) ->
    IGNORE e
    vals = (item.get 'item' for item in @model.items.where selected: true)
    unselected = @model.items.where selected: false

    if unselected.length is 0
      return @model.set error: (new Error 'All items are selected')

    # If we know all the possible values, and there are more selected than un-selected
    # values (above a certain cut-off), then make the smaller constraint. This means if
    # a user selects 95 of 100 values, the resulting constraint will only hold 5 values.
    if (not @hasMore()) and (MIN_VALS_OPTIMISATION > vals.length > unselected.length)
      return @constrainTo (negateOps ops), (item.get('item') for item in unselected)
    else # add the constraint as is.
      return @constrainTo ops, vals

  # The new constraint is either a multi-value constraint, a single-value constraint,
  # or a null constraint. Helper for addConstraint
  constrainTo: (ops, vals) ->
    return @model.set error: (new Error 'No values are selected') unless vals?.length
    [val] = vals

    newCon = switch
      when vals.length then {op: ops.multi, values: vals}
      when val? then {op: ops.single, value: String val}
      else {op: ops.absent}

    @model.query.addConstraint _.extend newCon, path: @model.view.toString()

  # Set the selection state for the items - helper for unsetSelection, toggleSelection
  changeSelection: (f) ->
    # The function is deferred so that any rendering that happens due to it
    # does not block iterating over the items.
    @model.items.each (item) -> _.defer f, item

