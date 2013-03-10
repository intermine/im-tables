do ->

  class ViewElement extends Backbone.View

    TEMPLATE = _.template """
      <div>
        <a class="im-col-remover" title="Remove this column" href="#">
          <i class="#{ intermine.icons.Remove }"></i>
        </a>
        <i class="icon-reorder pull-right"></i>
        <% if (replaces.length) { %>
          <i class="#{ intermine.icons.Collapsed } im-expander pull-right"></i>
        <% } %>
        <span class="im-display-name"><%- path %></span>
        <ul class="im-sub-views"></ul>
      </div>
    """

    placement: 'left'

    tagName: 'li'

    className: 'im-view-element im-reorderable'

    events:
      'click .im-col-remover': 'remove'
      'click .im-expander': 'toggleSubViews'

    toggleSubViews: ->
      @$('.im-sub-views').slideToggle()
      @$('.im-expander').toggleClass intermine.icons.ExpandCollapse

    remove: ->
      @model.destroy()
      @$('.im-col-remover').tooltip 'hide'
      super arguments...

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

      path.getDisplayName().done (name) => @$('.im-display-name').text name

      ul = @$('.im-sub-views')

      for replaced in @model.get('replaces') when replaced.isAttribute() then do (ul) ->
        li = $ '<li>'
        ul.append li
        replaced.getDisplayName().done (name) -> li.text name

      ul.remove() unless ul.children().length

      this


  scope 'intermine.columns.views', {ViewElement}
