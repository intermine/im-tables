$ = require 'jquery'

CoreView = require '../../core-view'
Templates = require '../../templates'
Messages = require '../../messages'

ClassSet = require '../../utils/css-class-set'
sortQueryByPath = require '../../utils/sort-query-by-path'
onChange = require '../../utils/on-change'

FormattedSorting = require '../formatted-sorting'
SingleColumnConstraints = require '../constraints/single-column'
DropDownColumnSummary = require './column-summary' # FIXME
OuterJoinDropDown = require './outerjoin-column-summary' # FIXME

{getFormatter} = require '../../path-formatting'

ignore = (e) ->
  e?.preventDefault()
  e?.stopPropagation()
  return false

module.exports = class ColumnHeader extends CoreView

  tagName: 'th'

  className: 'im-column-th'

  RERENDER_EVT: onChange [
    'expanded', 'name', 'outerJoined', 'minimised', 'composed', 'direction',
    'sortable', 'numOfCons', 'path'
  ]

  initialize: ({@query, @blacklistedFormatters}) ->
    super
    # Calculate derived properties. Sets @view and some model properties.
    @initModel()

    # Declare dependencies needed for recalculating the model.
    @listenForChange @model, @onPathChange, 'path'
    @listenForChange @model, @updateModel, 'path', 'replaces', 'isFormatted', 'minimisedCols'
    @listenForChange @query, @updateModel, 'sortorder', 'joins', 'constraints'
    @listenTo @query, 'subtable:expanded', @onSubtableExpanded
    @listenTo @query, 'subtable:collapsed', @onSubtableCollapsed
    @listenTo @query, 'showing:column-summary', @removeMySummary

    @listenTo Options, 'change:icons', @reRender

    @createClassSets()

  createClassSets: -> # Class sets that are always up-to-date.
    @classSets = {}
    isMinimised = => @model.get('minimisedCols')[@view]
    classSets.headerClasses = new ClassSet
      'im-column-header': true
      'im-minimised-th': isMinimised
      'im-is-composed': => @model.get 'composed'
      'im-has-constraint': => @model.get 'numOfCons'
    classSets.colTitleClasses = new ClassSet
      'im-col-title': true
      'im-hidden': isMinimised

  uc = (s) -> s?.toUpperCase()
  firstResult = _.compose _.first, _.compact, _.map

  initModel: ->
    @updateModel()
    @onPathChange()

  # Calculates derived properties,
  # setting @view, and model{minimised, name, isComposed, direction, sortable, numOfCons}
  updateModel: ->
    # These are properties of the model this method depends on.
    {isFormatted, name, path, replaces, minimisedCols} = @model.toJSON()
    replaces ?= [] # Should *always* be an array, but if undef set it as an empty one.
    {query} = @
    # The view this column actually represents.
    @view = String (if replaces.length is 1 and isFormatted then replaces[0] else path)

    outerJoined = query.isOuterJoined @view

    # Work out the sort direction of this column (which is the sort
    # direction of the path or the first available sort direction of
    # the paths it replaces in the case of formatted columns).
    direction = uc firstResult replaces.concat(@view), (p) -> query.getSortDirection p
    
    # We can sort by this column if it is fully inner joined.
    sortable = (not outerJoined)

    # This column is composed if it represents more than one replaced column.
    isComposed = (not outerJoined) and (replaces.length > 1)

    # The column is minimised when it is listed in the minimisedCols set
    minimised = minimisedCols[@view]

    # Make sure the model has the correct initial expansion state.
    @model.set(expanded: Options.get 'Subtables.Initially.expanded') unless @model.has 'expanded'
    # enforce that the model has a name so that templates won't throw errors.
    @model.set(name: '') unless @model.get 'name'
    @model.set
      outerJoined: outerJoined
      minimised: minimised
      composed: isComposed
      direction: direction
      sortable: sortable
      numOfCons: _.size(c for c in query.constraints when c.path.match @view)

  onPathChange: -> # Should never actually happen.
    @model.get('path').getDisplayName().then (name) => @model.set {name}

  # Make sure we are only showing one column summary at once, so make way for
  # other column summaries that are displayed.
  removeMySummary: (path) ->
    @removeChild 'summary' unless path.equals @model.get 'path'

  onSubtableExpanded: (node) ->
    @model.set(expanded: true) if node.toString().match @view

  onSubtableCollapsed: (node) ->
    @model.set(expanded: false) if node.toString().match @view

  getData: ->
    [ancestors..., penult, last] = parts = @model.get('name').split(' > ')
    parentType = if ancestors.length then 'non-root' else 'root'
    minimised = @model.get(minimisedCols)[@view]

    penultClasses = new ClassSet
      'im-title-part im-parent': true
      'im-root-parent': (not ancestors.length)
      'im-non-root-parent': (ancestors.length)
      'im-last': (not last) # in which case the penult is actually last.

    _.extend {penultClasses, colTitleClasses, last, penult, minimised}, @classSets, super

  template: Templates.template 'column_header'

  namePopoverTemplate: Templates.template 'column_name_popover'

  events: ->
    'click .im-col-sort': 'setSortOrder'
    'click .im-col-minumaximiser': 'toggleColumnVisibility'
    'click .im-col-filters': 'showFilterSummary'
    'click .im-subtable-expander': 'toggleSubTable'
    'click .im-col-remover': 'removeColumn'
    'toggle .im-th-button': 'summaryToggled' # should we use the bootstrap events

  postRender: ->
    @bindRecalcitrantButtons()
    @setTitlePopover()
    @announceExpandedState()
    @activateTooltips()
    @activateDropdowns()

  activateTooltips: -> @$('.im-th-button').tooltip
    placement: @bestFit
    container: @el

  activateDropdowns: -> @$('.dropdown .dropdown-toggle').dropdown()

  # Bind events to buttons that experience interference from dropdowns when
  # their events are bound from ::events
  bindRecalcitrantButtons: ->
    @$('.summary-img').click @showColumnSummary
    @$('.im-col-filters').click @showFilterSummary
    @$('.im-col-composed').click @addFormatterToBlacklist

  addFormatterToBlacklist: ->
    @blacklistedFormatters.add formatter: @model.get 'formatter'
    
  announceExpandedState: -> if @model.get 'expanded'
    @query.trigger 'expand:subtables', @model.get 'path'

  setTitlePopover: ->
    # title is html - cannot be implemented in the main template.
    title = @namePopoverTemplate @getData()
    @$('.im-col-title').popover {title, placement: 'bottom', html: true}

  summaryToggled: (e, isOpen) ->
    ignore e
    return unless e.target is e.currentTarget # Don't listen to bubbled events.
    @removeChild 'summary' unless isOpen

  hideTooltips: -> @$('.im-th-button').tooltip 'hide'

  removeColumn: (e) ->
    @hideTooltips()
    @query.removeFromSelect(v for v in @query.views when v.match @view)
    ignore e

  # Used to hook in and add the correct style prefix to the tip.
  bestFit: (tip, elem) =>
    $(tip).addClass Options.get 'StylePrefix'
    return 'top'

  checkHowFarOver: (el) ->
    bounds = @$el.closest '.im-table-container'
    if (el.offset().left + 350) >= (bounds.offset().left + bounds.width())
      @$el.addClass 'too-far-over'

  showSummary: (selector, View, e) =>
    ignore e

    return false if @$(selector).hasClass 'open'

    @query.trigger 'showing:column-summary', @model.get 'path'
    summary = new View {@query, @model}
    $menu = @$ selector + ' .dropdown-menu'
    throw new Error "#{ selector } not found" unless $menu.length
    $menu.empty()
    @renderChild 'summary', summary, $menu

  showColumnSummary: (e) =>
    cls = if @path().isAttribute()
      DropDownColumnSummary
    else
      OuterJoinDropDown

    @showSummary '.im-summary', cls, e

  showFilterSummary: (e) =>
    @showSummary '.im-filter-summary', SingleColumnConstraints, e

  toggleColumnVisibility: (e) =>
    ignore e
    @query.trigger 'columnvis:toggle', @view

  path: -> @model.get 'path'

  setSortOrder: (e) ->
    {direction, replaces} = @model.toJSON()
    if replaces.length # we need to let the use choose from amongst them.
      @showSummary '.im-col-sort', FormattedSorting, e
      @$('.im-col-sort').toggleClass 'open'
    else
      sortQueryByPath @query, @view
      @$('.im-col-sort').removeClass 'open'

  toggleSubTable: (e) =>
    ignore e
    isExpanded = @model.get 'expanded'
    cmd = if isExpanded then 'collapse' else 'expand'
    @query.trigger cmd + ':subtables', @model.get 'path'
    @model.set expanded: not isExpanded

