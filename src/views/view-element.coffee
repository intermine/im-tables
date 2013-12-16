Backbone = require 'backbone'
_ = require 'underscore'
icons = require '../icons'

class exports.ViewElement extends Backbone.View

  TEMPLATE = _.template """
    <div>
      <a class="im-col-remover" title="Remove this column">
        <i class="#{ icons.Remove }"></i>
      </a>
      <i class="icon-reorder pull-right"></i>
      <% if (replaces.length) { %>
        <i class="#{ icons.Collapsed } im-expander pull-right"></i>
      <% } %>
      <span class="im-display-name"><%- path %></span>
      <ul class="im-sub-views"></ul>
    </div>
  """

  placement: 'top'

  tagName: 'li'

  className: 'im-view-element im-reorderable'

  events:
    'click .im-col-remover': 'remove'
    'click': 'toggleSubViews'

  toggleSubViews: ->
    @$('.im-sub-views').slideToggle()
    @$('.im-expander').toggleClass icons.ExpandCollapse

  remove: ->
    @model.destroy()
    @$('.im-col-remover').tooltip 'hide'
    super arguments...

  namePart = _.template """<span class="im-name-part"><%- part %></span>"""

  splitName = ($elem) -> (name) ->
    parts = name.split ' > '
    for part in parts
      $elem.append namePart {part}

  render: ->
    path = @model.get 'path'

    # Horrible I know - but cannot get jQuery's data to work correctly.
    # For some reason `$elems.map -> $(@).data('key')` doesn't work. I couldn't
    # find anything about this on the interweb.
    @model.el = @el

    @$el.append TEMPLATE @model.toJSON()

    # TODO - these are not displaying correctly.
    @$('.im-col-remover').tooltip
      placement: @placement
      container: @el

    $name = @$('.im-display-name').empty()
    path.getDisplayName splitName $name

    ul = @$('.im-sub-views')

    for replaced in @model.get('replaces') when replaced.isAttribute() then do (ul) ->
      li = $ '<li></li>'
      ul.append li
      span = document.createElement 'span'
      li.append span
      span.className = 'im-display-name'
      replaced.getDisplayName splitName $ span

    ul.remove() unless ul.children().length

    this
