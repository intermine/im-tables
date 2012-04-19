scope "intermine.query.results", (exporting) ->

    exporting class DashBoard extends Backbone.View
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
            console.log "Rendering"
            promise = @service.query @query, (q) =>
                console.log "Made a query"
                main = @make "div", {class: @TABLE_CLASSES}
                @$el.append main
                @table = new intermine.query.results.Table(q, main)
                @table.render()

                @renderTools(q)

                q.on evt, cb for evt, cb of @queryEvents

            promise.fail (xhr, err, msg) =>
                console.log arguments
                @$el.append """
                    <div class="alert alert-error">
                        <h1>#{err}</h1>
                        <p>Unable to construct query: #{msg}</p>
                    </div>
                """
            this

        renderTools: (q) ->
            tools = @make "div", {class: "span3 im-query-toolbox"}
            @$el.append tools
            toolbar = new intermine.query.tools.Tools(q)
            toolbar.render().$el.appendTo tools


    exporting class CompactView extends DashBoard

        className: "query-display compact"

        TABLE_CLASSES: "im-query-results"

        renderTools: (q) ->
            toolbar = new intermine.query.tools.ToolBar(q)
            toolbar.render().$el.appendTo @el



