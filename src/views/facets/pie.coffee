Backbone = require 'backbone'
_ = require 'underscore'

options = require '../../options'
icons = require '../../icons'
{getMessage, getMessageSet} = require '../../messages'

InterMineView = require '../intermine-view'

FacetRow = require './facet-row'

class PieFacet extends InterMineView

  className: 'im-grouped-facet im-pie-facet im-facet'

  chartHeight: 100

  initialize: (@query, @facet, items, @hasMore, @filterTerm) ->
    @items = new Backbone.Collection(items)
    @items.each (item) -> item.set visibility: true, selected: false

    @items.maxCount = @items.first()?.get "count"
    @items.on "change:selected", =>
      someAreSelected = @items.any((item) -> !! item.get "selected")
      allAreSelected = !@items.any (item) -> not item.get "selected"
      @$('.im-filter .btn-group .btn').attr "disabled", !someAreSelected
      @$('.im-filter .btn-toggle-selection').attr("disabled", allAreSelected)
                                            .toggleClass("im-invert", someAreSelected)
    @items.on 'add', @addItemRow, @

  basicOps =
    single: '='
    multi: 'ONE OF'
    absent: 'IS NULL'

  negateOps = (ops) ->
    ret = {}
    ret.multi = if ops.multi is 'ONE OF' then 'NONE OF' else 'ONE OF'
    ret.single = if ops.single is '=' then '!=' else '='
    ret.absent = if ops.absent is 'IS NULL' then 'IS NOT NULL' else 'IS NULL'
    ret

  IGNORE_E = (e) -> e.preventDefault(); e.stopPropagation()

  events: ->
    'submit .im-facet form': IGNORE_E
    'click .im-filter .btn-cancel': 'resetOptions'
    'click .im-filter .btn-toggle-selection': 'toggleSelection'
    'click .im-export-summary': 'exportSummary'
    'click .im-load-more': 'loadMoreItems'
    'click .im-filter .im-filter-in': (e) => @addConstraint e, basicOps
    'click .im-filter .im-filter-out': (e) => @addConstraint e, negateOps basicOps
    'keyup .im-filter-values': _.throttle @filterItems, 750, {leading: false}
    'click .im-clear-value-filter': 'clearValueFilter'
    'click': IGNORE_E

  filterItems: (e) =>
    $input = @$ '.im-filter-values'
    current = $input.val()
    if @hasMore or (@filterTerm and current.length < @filterTerm.length)
      return if @_filter_queued
      @_filter_queued = true
      _.delay (=> @query.trigger 'filter:summary', $input.val()), 750
    else
      parts = (current ? '').toLowerCase().split /\s+/
      test = (str) -> _.all parts, (part) -> !!(str and ~str.toLowerCase().indexOf(part))
      @items.each (x) -> x.set visibility: test x.get 'item'

  clearValueFilter: ->
    $input = @$ '.im-filter-values'
    $input.val @filterTerm
    @items.each (x) -> x.set visibility: true

  loadMoreItems: ->
    return if @summarising
    loader = @$('.im-load-more')
    text = loader.text()
    loader.html """<i class="icon-refresh icon-spin"></i>"""
    @limit *= 2
    @summarising = @query.filterSummary @facet.path, @filterTerm, @limit
    @summarising.then (items, stats, fcount) =>
      @hasMore = stats.uniqueValues > @limit
      newItems = items.slice @items.length
      for newItem in newItems
        @items.add _.extend newItem, {visibility: true, selected: false}
      @query.trigger 'got:summary:total', @facet.path, stats.uniqueValues, items.length, fcount
    @summarising.then =>
      loader.empty().text text
      loader.toggle @hasMore
    @summarising.then (=> delete @summarising), (=> delete @summarising)

  exportSummary: (e) ->
    # The only purpose of this is to reinstate the default click behaviour which is
    # being swallowed by another click handler. This is really dumb, but for future
    # reference this is how you gazump someone else's click handlers.
    e.stopImmediatePropagation()
    return true
  
  changeSelection: (f) ->
    tbody = @$('.im-item-table tbody')[0]
    @items.each (item) => _.defer => f.call(@, item)

  resetOptions: (e) -> @changeSelection (item) -> item.set selected: false

  toggleSelection: (e) -> @changeSelection (item) ->
    item.set({selected: not item.get('selected')}) if item.get('visibility')

  addConstraint: (e, ops, vals) ->
    e.preventDefault()
    e.stopPropagation()
    newCon = path: @facet.path
    unless vals?
      vals = (item.get "item" for item in @items.where selected: true)
      unselected = @items.where selected: false
      if (not @hasMore) and vals.length > unselected.length
        return @addConstraint e, negateOps(ops), (item.get('item') for item in unselected)

    if vals.length is 1
      if vals[0] is null
          newCon.op = ops.absent
      else
          newCon.op = ops.single
          newCon.value = "#{vals[0]}"
    else
        newCon.op = ops.multi
        newCon.values = vals
    newCon.title = @facet.title unless @facet.ignoreTitle
    @query.addConstraint newCon

  render: ->
    @addChart()
    @addControls()
    this

  addChart: ->
    @chartElem = @make "div"
    @$el.append @chartElem
    setTimeout (=> @_drawD3Chart()), 0 if d3?
    this

  getChartPalette = ->
    {PieColors} = options
    if _.isFunction PieColors
      paint = PieColors
    else
      paint = d3.scale[PieColors]()

    (d, i) -> paint i

  _drawD3Chart: ->
    h = @chartHeight
    w = @$el.closest(':visible').width()
    r = h * 0.4
    ir = h * 0.1
    donut = d3.layout.pie().value (d) -> d.get 'count'

    colour = getChartPalette()

    chart = d3.select(@chartElem).append('svg')
      .attr('class', 'chart')
      .attr('height', h)
      .attr('width', w)

    arc = d3.svg.arc()
      .startAngle( (d) -> d.startAngle )
      .endAngle( (d) -> d.endAngle )
      .innerRadius((d) -> if d.data.get('selected') then ir + 5 else ir)
      .outerRadius((d) -> if d.data.get('selected') then r + 5 else r)

    arc_group = chart.append('svg:g')
      .attr('class', 'arc')
      .attr('transform', "translate(#{ w / 2},#{h / 2})")
    centre_group = chart.append('svg:g')
      .attr('class', 'center_group')
      .attr('transform', "translate(#{ w / 2},#{h / 2})")
    label_group = chart.append("svg:g")
      .attr("class", "label_group")
      .attr("transform", "translate(#{w/2},#{h/2})")

    whiteCircle = centre_group.append("svg:circle")
      .attr("fill", "white")
      .attr("r", ir)

    getTween = (d, i) ->
      j = d3.interpolate({startAngle: 0, endAngle: 0}, d)
      (t) -> arc j t
    
    paths = arc_group.selectAll('path').data(donut @items.models)
    paths.enter().append('svg:path')
      .attr('class', 'donut-arc')
      .attr('stroke', 'white')
      .attr('stroke-width', 0.5)
      .attr('fill', colour)
      .on('click', (d, i) -> d.data.set selected: not d.data.get 'selected')
      .on('mouseover', (d, i) -> d.data.trigger 'hover')
      .on('mouseout', (d, i) -> d.data.trigger 'unhover')
      .transition()
        .duration(options.D3.Transition.Duration)
        .attrTween('d', getTween)

    total = @items.reduce ((sum, m) -> sum + m.get 'count'), 0
    percent = (d) -> (d.data.get('count') / total * 100).toFixed(1)

    paths.each (d, i) ->
      title = "#{ d.data.get 'item' }: #{ percent d }%"
      placement = if (d.endAngle + d.startAngle) / 2 > Math.PI then 'left' else 'right'
      $(@).tooltip {title, placement, container: @chartElem}
    paths.transition()
      .duration(options.D3.Transition.Duration)
      .ease(options.D3.Transition.Easing)
      .attrTween("d", getTween)

    @items.on 'change:selected', =>
      paths.data(donut @items.models).attr('d', arc)
      paths.transition()
        .duration(options.D3.Transition.Duration)
        .ease(options.D3.Transition.Easing)

    this

  filterControls: """
    <div class="input-prepend">
        <span class="add-on im-clear-value-filter">
          <i class="icon-refresh"></i>
        </span>
        <input type="text" class="input-medium  im-filter-values" placeholder="Filter values">
    </div>
  """

  getDownloadPopover: ->
    {icons} = intermine
    lis = for param, name of SUMMARY_FORMATS
      href = """#{ @query.getExportURI param }&summaryPath=#{ @facet.path }"""
      i = """<i class="#{ icons[name] }"></i>"""
      """<li><a href="#{ href }"> #{ i } #{ name }</a></li>"""

    """<ul class="im-export-summary">#{ lis.join '' }</ul>"""

  addControls: ->
      {More, DownloadData, DownloadFormat} = getMessageSet 'facets'
      $grp = $ """
      <form class="form form-horizontal">
        #{ @filterControls }
        <div class="im-item-table">
          <table class="table table-condensed table-striped">
            <colgroup>
              #{ @colClasses.map( (cl) -> "<col class=#{cl}>").join('') }
            </colgroup>
            <thead>
              <tr>#{ @columnHeaders.map( (h) -> "<th>#{ h }</th>" ).join('') }</tr>
            </thead>
            <tbody class="scrollable"></tbody>
          </table>
          #{ if @hasMore then '<div class="im-load-more">' + More + '</div>' else '' }
        </div>
      </form>"""
      $grp.button()
      tbody = $grp.find('tbody')[0]
      @items.each (item) => @addItemRow item, @items, {}, tbody
      # TODO - there are a lot of strings to externalise here.
      $grp.append """
        <div class="im-filter">
          <button class="btn pull-right im-download" >
            <i class="#{ icons.Download }"></i>
            #{ DownloadData }
          </button>
          #{ @buttons() }
        </div>
      """

      $btns = $grp.find('.im-filter .btn').tooltip placement: 'top', container: @el
      $btns.on 'click', (e) -> $btns.tooltip 'hide'

      # The following is due to the insanity of bootstrap forcing
      # all dropdowns closed when another opens, preventing nested
      # dropdowns.
      $grp.find('.dropdown-toggle').click (e) ->
        $this = $ @
        $parent = $this.parent()

        $parent.toggleClass 'open'


      imd = $grp.find('.im-download').popover
        placement: 'top'
        html: true
        container: @el
        title: DownloadFormat
        content: @getDownloadPopover()
        trigger: 'manual'

      imd.click (e) -> imd.popover 'toggle'

      @initFilter($grp)

      $grp.appendTo @el

      this

  addItemRow: (item, items, opts, tbody) ->
    tbody ?= @$('.im-item-table tbody').get()[0]
    tbody.appendChild @makeRow item

  buttons: -> """
    <div class="btn-group">
      <button type="submit" class="btn btn-primary im-filter-in" disabled
              title="#{ getMessage 'facets.Include' }">
        Filter
      </button>
      <button class="btn btn-primary dropdown-toggle" 
              title="Select filter type"  disabled>
        <span class="caret"></span>
      </button>
      <ul class="dropdown-menu">
        <li>
          <a href="#" class="im-filter-in">
            #{ getMessage 'facets.Include' }
          </a>
        </li>
        <li>
          <a href="#" class="im-filter-out">
            #{ getMessage 'facets.Exclude' }
          </a>
        </li>
      </ul>
    </div>

    <div class="btn-group">
      <button class="btn btn-cancel" disabled
                title="#{ getMessage 'facets.Reset' }">
        <i class="#{ icons.Undo }"></i>
      </button>
      <button class="btn btn-toggle-selection"
              title="#{ getMessage 'facets.ToggleSelection' }">
        <i class="#{ icons.Toggle }"></i>
      </button>
    </div>
  """

  initFilter: ($grp) ->
    return unless @filterTerm?
    sel = '.im-filter-values'
    $valFilter = if $grp? then $grp.find(sel) else @$ sel
    $valFilter.val @filterTerm

  colClasses: ["im-item-selector", "im-item-value", "im-item-count"]

  columnHeaders: [' ', 'Item', 'Count']

  makeRow: (item) ->
    row = new FacetRow(item, @items)
    row.render().el
