CoreView = require '../../core-view'
Templates = require '../../templates'
Messages = require '../../messages'

Messages.set
  'table.header.FailedToInitSortMenu': 'Could not initialise the sorting menu.'
  'table.header.FailedToInitFilter': 'Could not initialise the filter menu.'
  'table.header.FailedToInitSummary': 'Could not intitialise the column summary.'
  'table.header.ViewSummary': 'View column summary'
  'table.header.ViewComposedParts': 'View as separate columns'
  'table.header.ToggleColumn': 'Toggle column visibility'
  'table.header.RemoveColumn': 'Remove this column'
  'table.header.SortColumn': 'Sort this column'
  'table.header.FilterTitle': """
    <% if (count > 0) { %>
      <%= count %> active filters.
    <% } else { %>
      Filter by values in this column.
    <% } %>
  """

# FIXME!!! This class is only partially done...
ignore = (e) ->
  e?.preventDefault()
  e?.stopPropagation()
  return false

NEXT_DIRECTION_OF =
  ASC: 'DESC'
  DESC: 'ASC'

module.exports = class ColumnHeader extends CoreView

  tagName: 'th'

  className: 'im-column-th'

  initialize: ({@query, @blacklistedFormatters}) ->
    super
    # Store this, as it will be needed several times.
    @view = @model.get('path').toString()
    if @model.get('replaces').length is 1 and @model.get('isFormatted')
      @view = @model.get('replaces')[0].toString()

    @namePromise = @model.get('path').getDisplayName()
    @namePromise.done (name) => @model.set {name}

    @updateModel()

    # TODO change to listenTo
    @query.on 'change:sortorder', @updateModel
    @query.on 'change:joins', @updateModel
    @query.on 'change:constraints', @updateModel
    @query.on 'change:minimisedCols', @minumaximise
    @query.on 'subtable:expanded', (node) =>
      @model.set(expanded: true) if node.toString().match @view
    @query.on 'subtable:collapsed', (node) =>
      @model.set(expanded: false) if node.toString().match @view
    @query.on 'showing:column-summary', (path) =>
      unless path.equals @model.get 'path'
        @summary?.remove()

    @model.on 'change:conCount', @displayConCount
    @model.on 'change:direction', @displaySortDirection
    intermine.onChangeOption 'Style.icons', @render, @

  getCompositionTitle = (replaces) -> """
    This column replaces #{ replaces.length } others. Click here
    to show the individual columns separately.
  """

  renderName: =>
    # TODO move this to getData.
    [ancestors..., penult, last] = parts = @model.get('name').split(' > ')
    parentType = if ancestors.length then 'non-root' else 'root'
    # TODO Move this to postRender
    title = @namePopoverTemplate @getData()
    @$('.im-col-title').popover {title, placement: 'bottom', html: true}

  # TODO Move to Model
  isComposed: ->
    return false if @query.isOuterJoined(@view)
    return (@model.get('replaces') or []).length > 1

  template: Templates.template 'column_header'

  namePopoverTemplate: Templates.template 'column_name_popover'

  render: ->

    @$el.empty()

    @$el.append @html()

    @displayConCount()
    @displaySortDirection()

    @namePromise.done @renderName

    # Does not work if placed in events, due to interference from dropdowns
    @$('.summary-img').click @showColumnSummary
    @$('.im-col-filters').click(@showFilterSummary)
    replaces = @model.get 'replaces'
    @$('.im-col-composed').attr(title: getCompositionTitle replaces).click =>
      @blacklistedFormatters.add formatter: @model.get 'formatter'

    @$el.toggleClass 'im-is-composed', @isComposed()

    @$('.im-th-button').tooltip
      placement: @bestFit
      container: @el

    @$('.dropdown .dropdown-toggle').dropdown()

    if not @model.get('path').isAttribute() and @query.isOuterJoined(@view)
      @addExpander()

    if @model.get 'expanded'
      @query.trigger 'expand:subtables', @model.get 'path'

    this

  firstResult = _.compose _.first, _.compact, _.map

  updateModel: =>
    direction = firstResult @model.get('replaces').concat(@view), (p) => @query.getSortDirection p
    @model.set
      direction: direction
      sortable: not @query.isOuterJoined @view
      conCount: (_.size _.filter @query.constraints, (c) => !!c.path.match @view)

  displayConCount: =>
    conCount = @model.get 'conCount'
    @$el.addClass 'im-has-constraint' if conCount

    @$('.im-col-filters').attr(title: COL_FILTER_TITLE conCount)

  html: ->
    data = _.extend {}, ICONS(), @model.toJSON()
    TEMPLATE data

  displaySortDirection: =>
    sortButton = @$ '.icon-sorting'
    {css_unsorted, ASC, DESC} = icons = ICONS()
    sortButton.addClass css_unsorted
    sortButton.removeClass ASC + ' ' + DESC
    if @model.has 'direction'
      sortButton.toggleClass css_unsorted + ' ' + icons[@model.get 'direction']

  events:
    'click .im-col-sort': 'setSortOrder'
    'click .im-col-minumaximiser': 'toggleColumnVisibility'
    'click .im-col-filters': 'showFilterSummary'
    'click .im-subtable-expander': 'toggleSubTable'
    'click .im-col-remover': 'removeColumn'
    'toggle .im-th-button': 'summaryToggled'

  summaryToggled: (e, isOpen) ->
    ignore e
    return unless e.target is e.currentTarget # Don't listen to bubbles.
    unless isOpen
      @summary?.remove()

  hideTooltips: -> @$('.im-th-button').tooltip 'hide'

  removeColumn: (e) ->
    @hideTooltips()
    unwanted = (v for v in @query.views when v.match @view)
    @query.removeFromSelect unwanted
    false

  bestFit: (tip, elem) =>
    $(tip).addClass intermine.options.StylePrefix
    return 'top'

  checkHowFarOver: (el) ->
    bounds = @$el.closest '.im-table-container'
    if (el.offset().left + 350) >= (bounds.offset().left + bounds.width())
        @$el.addClass 'too-far-over'

  showSummary: (selector, View) => (e) =>
    ignore e

    @checkHowFarOver if e? then $(e.currentTarget) else @$el

    unless @$(selector).hasClass 'open'
      @query.trigger 'showing:column-summary', @model.get 'path'
      summary = new View(@query, @model.get('path'), @model)
      $menu = @$ selector + ' .dropdown-menu'
      console.log "#{ selector } not found" unless $menu.length
      # Must append before render so that dimensions can be calculated.
      $menu.html summary.el
      summary.render()
      @summary = summary

    false

  showColumnSummary: (e) =>
    cls = if @path().isAttribute()
      intermine.query.results.DropDownColumnSummary
    else
      intermine.query.results.OuterJoinDropDown

    @showSummary('.im-summary', cls) e

  showFilterSummary: (e) =>
    @showSummary('.im-filter-summary', intermine.query.filters.SingleColumnConstraints) e

  toggleColumnVisibility: (e) =>
    e?.preventDefault()
    e?.stopPropagation()
    @query.trigger 'columnvis:toggle', @view

  minumaximise: (minimisedCols) =>
    {css_hide, css_reveal} = ICONS()
    $i = @$('.im-col-minumaximiser i').removeClass css_hide + ' ' + css_reveal
    minimised = minimisedCols[@view]
    $i.addClass if minimised then css_reveal else css_hide
    @$el.toggleClass 'im-minimised-th', !!minimised
    @$('.im-col-title').toggle not minimised

  path: -> @model.get 'path'

  setSortOrder: (e) =>
    {direction, replaces} = @model.toJSON()
    direction = NEXT_DIRECTION_OF[ direction ] ? 'ASC'
    formatter = intermine.results.getFormatter @path()
    if replaces.length
      @showSummary('.im-col-sort', intermine.query.FormattedSorting) e
      @$('.im-col-sort').toggleClass 'open'
    else
      @$('.im-col-sort').removeClass 'open'
      @query.orderBy [ {path: @view, direction} ]

  addExpander: ->
    expandAll = $ """
      <a href="#" 
          class="im-subtable-expander im-th-button"
          title="Expand/Collapse all subtables">
        <i class="#{ intermine.icons.Table }"></i>
      </a>
    """
    expandAll.tooltip placement: @bestFit
    @$('.im-th-buttons').prepend expandAll

  toggleSubTable: (e) =>
    ignore e
    isExpanded = @model.get 'expanded'
    cmd = if isExpanded then 'collapse' else 'expand'
    @query.trigger cmd + ':subtables', @model.get 'path'
    @model.set expanded: not isExpanded

