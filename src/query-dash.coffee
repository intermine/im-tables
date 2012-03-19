namespace "intermine.query.results", (public) ->

    public class DashBoard extends Backbone.View
        tagName: "div"
        className: "query-display row-fluid"

        initialize: (service, @query, @queryEvents) ->
            @events ?= {}
            if _(service).isString()
                @service = new intermine.Service root: service
            else if service.fetchModel
                ## Is premade for us.
                @service = service
            else
                @service = new intermine.Service service

        TABLE_CLASSES: "span9 im-query-results"

        render: ->
            @service.query @query, (q) =>
                main = @make "div", {class: @TABLE_CLASSES}
                @$el.append main
                @table = new intermine.query.results.Table(q, main)
                @table.render()

                @renderTools(q)

                q.on evt, cb for evt, cb of @queryEvents
            this

        renderTools: (q) ->
            tools = @make "div", {class: "span3 im-query-toolbox"}
            @$el.append tools
            toolbar = new intermine.query.tools.Tools(q)
            toolbar.render().$el.appendTo tools


    public class CompactView extends DashBoard

        className: "query-display compact"

        TABLE_CLASSES: "im-query-results"

        renderTools: (q) ->
            toolbar = new intermine.query.tools.ToolBar(q)
            toolbar.render().$el.appendTo @el



