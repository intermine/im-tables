CoreView = require '../../core-view'

module.export = class FacetRow extends CoreView

  tagName: "tr"

  className: "im-facet-row"

  isBelow: () ->
    parent = @$el.closest '.im-item-table'
    @$el.offset().top + @$el.outerHeight() > parent.offset().top + parent.outerHeight()

  isAbove: () ->
    parent = @$el.closest '.im-item-table'
    @$el.offset().top < parent.offset().top

  isVisible: () -> not (@isAbove() or @isBelow())

  initialize: (@item, @items) ->
    @item.facetRow = @
    @listenTo @item, "change:selected", => @onChangeSelected()
    @listenTo @item, "change:visibility", => @onChangeVisibility()

    @listenTo @item, 'hover', =>
      @$el.addClass 'hover'
      unless @isVisible()
        above = @isAbove()
        surrogate = $ """
          <div class="im-facet-surrogate #{ if above then 'above' else 'below'}">
            <i class="icon-caret-#{ if above then 'up' else 'down' }"></i>
            #{ @item.escape('item') }: #{ @item.escape('count') }
          </div>
        """
        itemTable = @$el.closest('.im-item-table').append surrogate
        newTop = if above
          itemTable.offset().top + itemTable.scrollTop()
        else
          itemTable.scrollTop() + itemTable.offset().top + itemTable.outerHeight() - surrogate.outerHeight()
        surrogate.offset top: newTop

    @listenTo @item, 'unhover', =>
      @$el.removeClass 'hover'
      s = @$el.closest('.im-item-table').find('.im-facet-surrogate').fadeOut 'fast', () ->
        s.remove()

  initState: ->
    @onChangeVisibility()
    @onChangeSelected()

  onChangeVisibility: ->
    @$el.toggle @item.get "visibility"

  onChangeSelected: ->
    isSelected = !!@item.get "selected"
    if @item.has "path"
      item.get("path").node.setAttribute "class", if isSelected then "selected" else ""
    f = =>
    @$el.toggleClass "active", isSelected
    if isSelected isnt @$('input').prop("checked")
      @$('input').prop "checked", isSelected
    setTimeout f, 0

  events:
    'click': 'handleClick'
    'change input': 'handleChange'

  rowTemplate = _.template """
    <td class="im-selector-col">
      <span><%= symbol %></span>
      <input type="checkbox">
    </td>
    <td class="im-item-col">
      <% if (item != null) { %><%= item %><% } else { %><span class=null-value>&nbsp;</span><% } %>
    </td>
    <td class="im-count-col">
      <div class="im-facet-bar"
          style="width:<%= percent %>%;background:rgba(206, 210, 222, <%= opacity %>})">
        <span class="im-count">
        <%= count %>
        </span>
      </div>
    </td>
  """

  render: ->
    ratio = parseInt(@item.get("count"), 10) / @items.maxCount
    opacity = ratio.toFixed(2) / 2 + 0.5
    percent = (ratio * 100).toFixed(1)

    # TODO: there is a hard coded color here - this should live in css somehow.
    @$el.append rowTemplate _.extend {opacity, percent, symbol: ''}, @item.toJSON()
    if @item.get "percent"
      @$el.append """<td class="im-prop-col"><i>#{@item.get("percent").toFixed()}%</i></td>"""

    @initState()

    this

  handleClick: (e) ->
    e.stopPropagation()
    if e.target.type isnt 'checkbox'
      @$('input').trigger "click"

  handleChange: (e) ->
    e.stopPropagation()
    setTimeout (=> @item.set "selected", @$('input').is ':checked'), 0

