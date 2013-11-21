do ->

    # When underscore 1.4.4 is widely available, this can be replaced by
    # _.partial, but better to use our own for now.
    curry = intermine.funcutils.curry

    TAB_HTML = _.template """
        <li>
            <a href="#<%= ref %>" data-toggle="tab">
                <%= title %>
            </a>
        </li>
    """

    PANE_HTML = _.template """
        <div class="tab-pane" id="<%= ref %>"></div>
    """

    class Tools extends Backbone.View
        className: "im-query-tools"

        initialize: (@states) ->

        render: ->
            tabs = @make "ul",
                class: "nav nav-tabs"
            conf = [
                filters =
                    title: "Filters"
                    ref: "filters"
                    view: intermine.query.filters.Filters
                , columns =
                    title: "Columns"
                    ref: "columns"
                    view: intermine.query.columns.Columns
                , actions =
                    title: "Actions"
                    ref: "actions"
                    view: intermine.query.actions.Actions
            ]
            for c in conf
                $(tabs).append TAB_HTML(c)

            @$el.append tabs

            content = @make "div",
                class: "tab-content"

            for c in conf
                $pane = $(PANE_HTML(c)).appendTo content
                view = new c.view(@query)
                $pane.append view.render().el

            $(content).find('.tab-pane').first().addClass "active"
            $(tabs).find("a").first().tab 'show'

            @$el.append content

            this

    # This is a ridiculous class that must be killed. TODO: delete this class.
    class ToolBar extends Backbone.View

      className: "im-query-actionbar"

      initialize: (@states) ->

      render: ->
        actions = new intermine.query.actions.ActionBar @states
        try
          actions.render().$el.appendTo @el
        catch e
          console.error "Failed to set up toolbar because: #{ e.message }", e.stack

        this

    class Step extends Backbone.View

        className: 'im-step'
        tagName: 'li'

        nts = (n) -> intermine.utils.numToString n, ',', 3

        initialize: (opts) ->
            super(opts)
            @model.on 'change:count', (m, count) =>
              @$('.im-step-count .count').text nts count

            @model.on 'change:current', @renderCurrency, @
            @model.on 'remove', () => @remove()

        events:
            'click .icon-info-sign': 'showDetails'
            'click h4': 'toggleSection'
            'click .btn': 'revertToThisState'

        toggleSection: (e) ->
            e.stopPropagation()
            $(e.target).find('i').toggleClass("icon-chevron-right icon-chevron-down")
            $(e.target).next().children().toggle()

        showDetails: (e) ->
            e.stopPropagation()
            @$('.im-step-details').toggle()

        revertToThisState: (e) ->
            @model.trigger 'revert', @model
            @$('.btn-small').tooltip('hide')
        
        renderCurrency: ->
          isCurrent = @model.get 'current'
          @$('.btn').toggleClass('btn-inverse', not isCurrent).attr disabled: isCurrent
          @$('.btn-main').text if isCurrent then "Current State" else "Revert to this State"
          @$('.btn i').toggleClass('icon-white', not isCurrent)

        sectionTempl: _.template """
            <div>
              <h4>
                <i class="icon-chevron-right"></i>
                <%= n %> <%= things %>
              </h4>
              <table></table>
            </div>
          """

        cell = (content) -> $('<td>').html(content)

        toLabel = (type) -> (text) ->
          cell """<span class="label label-#{ type }">#{ text }</span>"""

        toPathLabel = toLabel 'path'
        toInfoLabel = toLabel 'info'
        toValLabel  = toLabel 'value'
      
        template: _.template """
          <button class="btn btn-small im-state-revert" disabled
              title="Revert to this state">
              <i class=icon-undo></i>
          </button>
          <h3><%- title %></h3>
          <i class="icon-info-sign"></i>
          </div>
          <span class="im-step-count">
              <span class="count"><%- count %></span> rows
          </span>
          <div class="im-step-details">
          <div style="clear:both"></div>
        """

        addSection: (xs, things, toPath, f) ->
          n  = _.size xs
          return if n < 1
          q  = @model.get('query')
          table = $(@sectionTempl {n, things}).appendTo(@$('.im-step-details')).find('table')
          for own k, v of xs then do (k, v) ->
            row = $ '<tr>'
            table.append row
            q.getPathInfo(toPath(k, v)).getDisplayName (name) -> f row, name, k, v

        getData: ->
          data = count: if @model.has('count') then nts(@model.get('count')) else ''
          _.defaults data, @model.toJSON()

        render: () ->
            @$el.attr(step: @model.get 'stepNo')
            @$el.append @template @getData()

            @renderCurrency()

            q = @model.get 'query'

            @$('.btn-small').tooltip placement: 'right'

            ps = (q.getPathInfo(v) for v in q.views)
            @addSection ps, 'Columns', ((i, x) -> x), (row, name) ->
              row.append toPathLabel name

            @addSection q.constraints, 'Filters', ((i, c) -> c.path), (row, name, i, c) ->
              row.append toPathLabel name
              if c.type?
                row.append toInfoLabel 'isa'
                row.append toValLabel c.type
              if c.op?
                row.append toInfoLabel c.op
              if c.value?
                row.append toValLabel c.value
              else if c.values?
                row.append toValLabel c.values.join(', ')

            @addSection q.joins, 'Joins', ((p, style) -> p), (row, name, p, style) ->
              row.append toPathLabel name
              row.append toInfoLabel style

            @addSection q.sortOrder, 'Sort Order Elements', ((i, so) -> so.path), (row, name, i, {direction}) ->
              row.append toPathLabel name
              row.append toInfoLabel direction

            this

    class Trail extends Backbone.View
        
        className: "im-query-trail"
        tagName: "div"

        initialize: (@states) ->
          @subViews = []
          @states.on 'add', @appendState, @
          @states.on 'reverted', @render, @

        events:
            'click a.details': 'minumaximise'
            'click a.shade': 'toggle'
            'click a.im-undo': 'undo'

        toggle: -> @$('.im-step').slideToggle 'fast', () => @$el.toggleClass "toggled"

        minumaximise: -> @$el.toggleClass "minimised"
            
        undo: -> @states.popState()

        appendState: (state) ->
          step = new Step(model: state)
          @subViews.push step
          @$('.im-state-list').append step.render().el
          @$el.addClass 'im-has-history'

        render: () ->
          while step = @subViews.pop()
            step.remove()
          @$el.html """
            <div class="btn-group">
              <a class="btn im-undo">
                <i class="#{ intermine.icons.Undo }"></i>
                <span class="visible-desktop">Undo</span>
              </a>
              <a class="btn dropdown-toggle" data-toggle="dropdown">
                <span class="caret"></span>
              </a>
              <ul class="dropdown-menu im-state-list">
              </ul>
            </div>
            <div style="clear:both"></div>
          """
          @states.each (s) => @appendState(s)
          @$el.toggleClass 'im-has-history', @states.size() > 1
          this

    scope "intermine.query.tools", {Tools, ToolBar, Trail}
