scope "intermine.query.tools", (exporting) ->

    ## Define stuff...

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

    exporting class Tools extends Backbone.View
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

    exporting class ToolBar extends Backbone.View

        className: "im-query-actionbar"

        initialize: (@query) ->

        render: ->
            actions = new intermine.query.actions.ActionBar(@query)
            actions.render().$el.appendTo @el

            this

