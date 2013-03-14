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

        initialize: (@query) ->

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

      initialize: (@query) ->

      render: ->
        actions = new intermine.query.actions.ActionBar(@query)
        try
          actions.render().$el.appendTo @el
        catch e
          console.error "Failed to set up toolbar because: #{ e.message }", e.stack

        this

    class Step extends Backbone.View

        className: 'im-step'
        tagName: 'li'

        initialize: (opts) ->
            super(opts)
            @model.on 'got:count', (count) =>
                @$('.im-step-count .count').text intermine.utils.numToString count, ',', 3

            @model.on 'is:current', (isCurrent) =>
                @$('.btn').toggleClass('btn-inverse', not isCurrent).attr disabled: isCurrent
                @$('.btn-main').text if isCurrent then "Current State" else "Revert to this State"
                @$('.btn i').toggleClass('icon-white', not isCurrent)

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

        sectionTempl: _.template """
                <div>
                    <h4>
                        <i class="icon-chevron-right"></i>
                        <%= n %> <%= things %>
                    </h4>
                    <ul></ul>
                </div>
            """

        toLabel = (type, text) ->
          """<span class="label label-#{ type }">#{ text }</span>"""

        toPathLabel = curry toLabel, 'path'
        toInfoLabel = curry toLabel, 'info'
        toValLabel  = curry toLabel, 'value'

        render: () ->
            @$el.attr(step: @model.get 'stepNo')
            @$el.append """
                    <button class="btn btn-small im-state-revert" disabled
                        title="Revert to this state">
                        <i class=icon-undo></i>
                    </button>
                    <h3>#{ @model.get 'title' }</h3>
                    <i class="icon-info-sign"></i>
                    </div>
                    <span class="im-step-count">
                        <span class="count"></span> rows
                    </span>
                    <div class="im-step-details">
                    <div style="clear:both"></div>
                """

            q = @model.get 'query'
            addSection = (n, things) =>
                $(@sectionTempl n: n, things: things).appendTo(@$('.im-step-details')).find('ul')

            @$('.btn-small').tooltip placement: 'right'

            ps = (q.getPathInfo(v) for v in q.views)
            vlist = addSection(ps.length, 'Columns')
            for p in ps then do (p) ->
                li = $ '<li>'
                vlist.append li
                p.getDisplayName (name) -> li.append toPathLabel name

            clist = addSection(q.constraints.length, 'Filters')
            for c in q.constraints then do (c) =>
                li = $ '<li>'
                clist.append li
                q.getPathInfo(c.path).getDisplayName (name) ->
                    li.append toPathLabel name
                    li.append toInfoLabel c.op
                    if c.value?
                        li.append toValLabel c.value
                    else if c.values?
                        li.append toValLabel c.values.join(', ')
            
            jlist = addSection _.size(q.joins), 'Joins'
            for path, style of q.joins then do (path, style) =>
                li = $ '<li>'
                jlist.append li
                q.getPathInfo(path).getDisplayName (name) ->
                    li.append toPathLabel name
                    li.append toInfoLabel style

            this

    class Trail extends Backbone.View
        
        className: "im-query-trail"
        tagName: "div"

        initialize: (@states) ->
          @states.on 'add', @appendState, @
          @states.on 'add remove', @renderSummary, @

        events:
            'click a.details': 'minumaximise'
            'click a.shade': 'toggle'
            'click a.im-undo': 'undo'

        toggle: -> @$('.im-step').slideToggle 'fast', () => @$el.toggleClass "toggled"

        minumaximise: -> @$el.toggleClass "minimised"
            
        undo: -> @states.popState()

        renderSummary: ->
          @$('.im-trail-summary').text """query history: #{ @states.size() } states"""
          @$el.toggle @states.size() > 1

        appendState: (state) ->
          @$('.im-state-list').append new Step(model: state).render().el

        render: () ->
          @$el.append """
            <div class="btn-group">
              <a class="btn im-undo" href="#">
                <i class="#{ intermine.icons.Undo }"></i>
                Undo
              </a>
              <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
                <span class="caret"></span>
              </a>
              <ul class="dropdown-menu im-state-list">
              </ul>
            </div>
            <div style="clear:both"></div>
          """
          @states.each (s) => @appendState(s)
          @renderSummary()
          this

    scope "intermine.query.tools", {Tools, ToolBar, Trail}
