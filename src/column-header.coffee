do ->

  ignore = (e) ->
    e?.preventDefault()
    e?.stopPropagation()
    return false


  ICONS = ->
    ASC: intermine.css.sortedASC
    DESC: intermine.css.sortedDESC
    css_unsorted: intermine.css.unsorted
    css_header: intermine.css.headerIcon
    css_remove: intermine.css.headerIconRemove
    css_hide: intermine.css.headerIconHide
    css_reveal: intermine.css.headerIconReveal
    css_filter: intermine.icons.Filter
    css_summary: intermine.icons.Summary


  TEMPLATE = _.template """ 
    <div class="im-column-header">
      <div class="im-th-buttons">
        <% if (sortable) { %>
          <a href="#" class="im-th-button im-col-sort-indicator" title="sort this column">
            <i class="icon-sorting <%- css_unsorted %> <%- css_header %>"></i>
          </a>
        <% }; %>
        <a href="#" class="im-th-button im-col-remover" title="remove this column" data-view="<%= view %>">
          <i class="<%- css_remove %> <%- css_header %>"></i>
        </a>
        <a href="#" class="im-th-button im-col-minumaximiser" title="Toggle column" data-col-idx="<%= i %>">
          <i class="<%- css_hide %> <%- css_header %>"></i>
        </a>
        <div class="dropdown im-filter-summary">
          <a href="#" class="im-th-button im-col-filters dropdown-toggle"
             title=""
             data-toggle="dropdown" data-col-idx="<%= i %>" >
            <i class="<%- css_filter %> <%- css_header %>"></i>
          </a>
          <div class="dropdown-menu">
            <div>Could not ititialise the filter summary.</div>
          </div>
        </div>
        <div class="dropdown im-summary">
          <a href="#" class="im-th-button summary-img dropdown-toggle" title="column summary"
            data-toggle="dropdown" data-col-idx="<%= i %>" >
            <i class="<%- css_summary %> <%- css_header %>"></i>
          </a>
          <div class="dropdown-menu">
            <div>Could not ititialise the column summary.</div>
          </div>
        </div>
      </div>
      <div style="clear:both"></div>
      <div class="im-col-title">
        <%- view %>
      </div>
    </div>
  """

  COL_FILTER_TITLE = (count) ->
      if (count > 0) then "#{ count } active filters" else "Filter by values in this column"

  RENDER_TITLE = _.template """
    <% _.each(titleParts, function(part, idx) { %>
      <% var penult = "" %>
      <% if (idx > 0 && idx == titleParts.length - 2) penult = "im-penult" %>
      <div class="im-title-part <%= penult %>"><%- part %></div>
    <% }); %>
  """


  class ColumnHeader extends Backbone.View

    tagName: 'th'

    className: 'im-column-th'

    initialize: (@query, @path) ->
      # Store this, as it will be needed several times.
      @view = @path.toString()
      isFormatted = intermine.results.shouldFormat @path

      @model = new Backbone.Model
        view: @view
        i: @query.views.indexOf @view
        isFormatted: isFormatted

      @namePromise = (if isFormatted then @path.getParent() else @path).getDisplayName()
      @namePromise.done (name) => @model.set {name}

      @updateModel()

      @query.on 'change:sortorder', @updateModel
      @query.on 'change:joins', @updateModel
      @query.on 'change:constraints', @updateModel
      @query.on 'change:minimisedCols', @minumaximise
      @query.on 'subtable:expanded', (node) =>
        @model.set(expanded: true) if node.toString().match @view
      @query.on 'subtable:collapsed', (node) =>
        @model.set(expanded: false) if node.toString().match @view

      @model.on 'change:conCount', @displayConCount
      @model.on 'change:direction', @displaySortDirection

    render: ->

      @$el.empty()

      @$el.append @html()

      @displayConCount()
      @displaySortDirection()

      @namePromise.done =>
        titleParts = @model.get('name').split(' > ')
        @$('.im-col-title').html RENDER_TITLE {titleParts}

      @$('.im-th-button').tooltip placement: @bestFit

      @$('.summary-img').click @showColumnSummary
      @$('.im-col-filters').click @showFilterSummary

      @$('.dropdown .dropdown-toggle').dropdown()

      unless @path.isAttribute()
        @addExpander()

      this


    updateModel: =>
      @model.set
        direction: @query.getSortDirection @view
        sortable: not @query.isOuterJoined @view
        conCount: (_.size _.filter @query.constraints, (c) => !!c.path.match @view)

    displayConCount: =>
      conCount = @model.get 'conCount'
      @$el.addClass 'im-has-constraint' if conCount

      @$('.im-col-filters').attr title: COL_FILTER_TITLE conCount

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
      'click .im-col-sort-indicator': 'setSortOrder'
      'click .im-col-minumaximiser': 'toggleColumnVisibility'
      'click .im-col-filters': 'showFilterSummary'
      'click .im-summary': 'showColumnSummary'
      'click .im-subtable-expander': 'toggleSubTable'
      'click .im-col-remover': 'removeColumn'

    hideTooltips: -> @$('.im-th-button').tooltip 'hide'

    removeColumn: (e) ->
      @hideTooltips()
      unwanted = (v for v in @query.views when v.match @view)
      @query.removeFromSelect unwanted
      false

    bestFit: (tip, elem) =>
      bounds = @$el.closest '.im-table-container'
      outOfBounds = @$el.offset().left - $(tip).width() <= bounds.offset().left
      if outOfBounds then 'right' else 'left'

    checkHowFarOver: ->
      bounds = @$el.closest '.im-table-container'
      if (@$el.offset().left + 350) >= (bounds.offset().left + bounds.width())
          @$el.addClass 'too-far-over'

    showSummary: (selector, View) => (e) =>
      ignore e
      @checkHowFarOver()
      unless @$(selector).hasClass 'open'
        path = if not @path.isAttribute() or @model.get 'isFormatted'
          @path.getParent()
        else
          @path

        summary = new View(@query, @path)
        $menu = @$ selector + ' .dropdown-menu'
        # Must append before render so that dimensions can be calculated.
        $menu.html summary.el
        summary.render()

      false
  
    showColumnSummary: (e) =>
      cls = if not @path.isAttribute() or @model.get 'isFormatted'
        intermine.query.results.OuterJoinDropDown
      else
        intermine.query.results.DropDownColumnSummary

      @showSummary('.im-summary', cls) e

    showFilterSummary: (e) =>
      @showSummary('.im-filter-summary', intermine.query.filters.SingleColumnConstraints) e

    toggleColumnVisibility: (e) =>
      e?.preventDefault()
      e?.stopPropagation()
      @query.trigger 'columnvis:toggle', @view

    minumaximise: (minimisedCols) =>
      {css_hide, css_reveal} = ICONS()
      $i = $('i', e.target).removeClass css_hide + ' ' + css_reveal
      minimised = minimisedCols[@view]
      $i.addClass if minimised then css_reveal else css_hide
      @$('.im-col-title').toggle not minimised

    setSortOrder: (e) =>
      e?.preventDefault()
      e?.stopPropagation()
      currentDirection = @model.get('direction')
      direction = ResultsTable.nextDirections[ currentDirection ] ? 'ASC'
      @query.orderBy [ {@path, direction} ]

    addExpander: ->
      expandAll = $ """
        <a href="#" 
           class="im-subtable-expander im-th-button"
           title="Expand/Collapse all subtables">
          <i class="icon-table icon-white"></i>
        </a>
      """
      expandAll.tooltip placement: @bestFit
      @$('.im-th-buttons').prepend expandAll

    toggleSubTable: (e) =>
      ignore e
      cmd = if @model.get 'expanded' then 'collapse' else 'expand'
      @query.trigger cmd + ':subtables', @path
      @model.set expanded: not @model.get 'expanded'

  scope 'intermine.query.results', {ColumnHeader}
