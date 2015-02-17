_ = require 'underscore'

CoreView = require '../../core-view'
Collection = require '../../core/collection'
Templates = require '../../templates'
Messages = require '../../messages'
Options = require '../../options'

ClassSet = require '../../utils/css-class-set'
sortQueryByPath = require '../../utils/sort-query-by-path'
onChange = require '../../utils/on-change'

HeaderModel = require '../../models/header'

# Check that all these can accept a HeaderModel as their model
FormattedSorting = require '../formatted-sorting'
SingleColumnConstraints = require '../constraints/single-column'
DropDownColumnSummary = require './column-summary'
OuterJoinDropDown = require './outer-join-summary'

{ignore} = require '../../utils/events'

require '../../messages/table' # Our messages live here.

ModelReader = (model, attr) -> -> model.get attr

getViewPortHeight = ->
  Math.max(document.documentElement.clientHeight, window.innerHeight || 0)

getViewPortWidth = ->
  Math.max(document.documentElement.clientWidth, window.innerWidth || 0)

module.exports = class ColumnHeader extends CoreView

  Model: HeaderModel

  tagName: 'th'

  className: 'im-column-th'

  RERENDER_EVENT: onChange [ # All the things that would cause us to re-render.
    'composed',
    'expanded',
    'minimised',
    'numOfCons',
    'outerJoined',
    'parts',
    'path'
    'sortable',
    'sortDirection',
  ]

  template: Templates.template 'column-header'

  namePopoverTemplate: Templates.template 'column_name_popover'

  parameters: ['query']
  optionalParameters: [
    'blacklistedFormatters',
    'expandedSubtables',
  ]

  # Default values of optional parameters.
  expandedSubtables: new Collection
  blacklistedFormatters: new Collection

  initialize: ->
    super

    @listenTo @query, 'showing:column-summary', @removeMySummary

    @listenTo Options, 'change:icons', @reRender

    @createClassSets()

  path: -> @model.pathInfo()

  createClassSets: -> # Class sets that are always up-to-date.
    @classSets = {}
    @classSets.headerClasses = new ClassSet
      'im-column-header': true
      'im-minimised-th': ModelReader @model, 'minimised'
      'im-is-composed': ModelReader @model, 'composed'
      'im-has-constraint': ModelReader @model, 'numOfCons'
    @classSets.colTitleClasses = new ClassSet
      'im-col-title': true
      'im-hidden': ModelReader @model, 'minimised'

  # Make sure we are only showing one column summary at once, so make way for
  # other column summaries that are displayed.
  removeMySummary: (path) -> unless path.equals @model.pathInfo()
    @removeChild 'summary'
    @$('.dropdown.open').removeClass 'open'

  onSubtableExpanded: (node) -> if node.toString().match @model.getView()
    @model.set expanded: true

  onSubtableCollapsed: (node) -> if node.toString().match @model.getView()
    @model.set expanded: false

  getData: ->
    [ancestors..., penult, last] = parts = @model.get 'parts'
    hasAncestors = ancestors.length
    parentType = if hasAncestors then 'non-root' else 'root'

    # We re-create because the alternative is needless re-calculation
    # of ancestors and last.
    penultClasses = new ClassSet
      'im-title-part im-parent': true
      'im-root-parent': (not hasAncestors)
      'im-non-root-parent': hasAncestors
      'im-last': (not last) # in which case the penult is actually last.

    _.extend {penultClasses, last, penult}, @classSets, super

  events: ->
    'click .im-col-sort': 'setSortOrder'
    'click .im-col-minumaximiser': 'toggleColumnVisibility'
    'click .im-col-filters': 'showFilterSummary'
    'click .im-subtable-expander': @toggleSubTable
    'click .im-col-remover': 'removeColumn'
    'hidden.bs.dropdown': -> @removeChild 'summary'
    'shown.bs.dropdown': 'onDropdownShown'
    'toggle .im-th-button': 'summaryToggled'
    'click .summary-img': @showColumnSummary
    'click .im-col-composed': @addFormatterToBlacklist

  postRender: ->
    @setTitlePopover()
    @announceExpandedState()
    @activateTooltips()

  activateTooltips: -> @$('.im-th-button').tooltip
    placement: 'top'
    container: @el

  onDropdownShown: (e) -> _.defer ->
    # Reset the right prop, so that the following calculation returns the truth.
    delete e.target.style.right
    ddRect = e.target.getBoundingClientRect()
    if ddRect.left < 0
      right = "#{ ddRect.left }px"
      e.target.style.right = right

  addFormatterToBlacklist: ->
    @blacklistedFormatters.add formatter: @model.get 'formatter'
    
  announceExpandedState: -> if @model.get 'expanded'
    @query.trigger 'expand:subtables', @model.get 'path'

  setTitlePopover: -> if Options.get('TableHeader.FullPathPopoverEnabled')
    # title is html - cannot be implemented in the main template.
    @$('.im-col-title').popover
      content: => @namePopoverTemplate @getData()
      container: @el
      placement: 'bottom'
      html: true

  summaryToggled: (e, isOpen) ->
    ignore e
    return unless e.target is e.currentTarget # Don't listen to bubbled events.
    @removeChild 'summary' unless isOpen

  hideTooltips: -> @$('.im-th-button').tooltip 'hide'

  removeColumn: (e) ->
    ignore e
    @hideTooltips()
    view = @model.getView()
    @query.removeFromSelect(v for v in @query.views when v.match view)

  checkHowFarOver: (el) ->
    bounds = @$el.closest '.im-table-container'
    if (el.offset().left + 350) >= (bounds.offset().left + bounds.width())
      @$el.addClass 'too-far-over'

  # Generic helper that will show a view in a dropdown menu which it shows.
  showSummary: (selector, View, e) =>
    ignore e
    $sel = @$ selector
    path = @path()

    if $sel.hasClass 'open'
      @query.trigger 'hiding:column-summary', path
      $sel.removeClass 'open'
      @children.summary?.$el.hide() # improves performance with large summaries
      @removeChild 'summary'
      return false
    else
      @$('.dropdown.open').removeClass 'open' # in case we already have one open.
      @query.trigger 'showing:column-summary', path
      summary = new View {@query, @model}
      $menu = @$ selector + ' .dropdown-menu'
      throw new Error "#{ selector } not found" unless $menu.length
      $menu.empty() # Whatever we are showing replaces all the content.
      @renderChild 'summary', summary, $menu
      $sel.addClass 'open'
      @onDropdownShown target: $menu[0]
      return true

  ensureDropdownIsWithinTable: (target, selector, minWidth = 360) ->
    elRect = target.getBoundingClientRect()
    table = @$el.closest('table')[0]
    return unless table?
    h = getViewPortWidth()
    $menu = @$ selector + ' .dropdown-menu'
    if minWidth >= h
      return $menu.addClass('im-fullwidth-dropdown').css width: h
    else
      $menu.css width: null

    return if (minWidth >= getViewPortWidth())
    tableRect = table.getBoundingClientRect()
    if (elRect.left + minWidth  > tableRect.right)
      @$(selector + ' .dropdown-menu').addClass 'dropdown-menu-right'

  showColumnSummary: (e) =>
    cls = if @model.get 'isReference'
      OuterJoinDropDown
    else
      DropDownColumnSummary

    if shown = @showSummary '.im-summary', cls, e
      h = getViewPortHeight() # Allow taller tables on larger screens.
      @$('.im-item-table').css 'max-height': Math.max 350, (h / 2)
      @ensureDropdownIsWithinTable e.target, '.im-summary'

  showFilterSummary: (e) =>
    if shown = @showSummary '.im-filter-summary', SingleColumnConstraints, e
      @ensureDropdownIsWithinTable e.target, '.im-filter-summary', 500

  toggleColumnVisibility: (e) =>
    ignore e
    @model.toggle 'minimised'

  setSortOrder: (e) ->
    ignore e
    if @model.get('replaces').length # we need to let the user choose
      @showSummary '.im-col-sort', FormattedSorting, e
    else
      sortQueryByPath @query, @model.getView()
      @$('.im-col-sort').removeClass 'open'

  toggleSubTable: (e) ->
    ignore e
    @expandedSubtables.toggle @model.pathInfo()

