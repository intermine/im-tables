do ->

    class DashBoard extends Backbone.View
        tagName: "div"
        className: "query-display row-fluid"

        initialize: (service, @query, @queryEvents, @tableProperties) ->
            console.log @tableProperties
            @columnHeaders = new Backbone.Collection
            @events ?= {}
            if _(service).isString()
                @service = new intermine.Service root: service
            else if service.fetchModel
                ## Is premade for us.
                @service = service
            else
                @service = new intermine.Service service

        TABLE_CLASSES: "span9 im-query-results"

        loadQuery: (q) ->
          @main.empty()
          @table = new intermine.query.results.Table(q, @main, @columnHeaders)
          @table[k] = v for k, v of @tableProperties
          @table.render()
          q.on evt, cb for evt, cb of @queryEvents

        render: ->
          @$el.addClass intermine.options.StylePrefix
          promise = @service.query @query
          
          promise.done (q) =>
            @tools = $ """<div class="clearfix">"""
            @$el.append @tools
            @main = $ """<div class="#{ @TABLE_CLASSES }">"""
            @$el.append @main

            @renderQueryManagement(q)
            @renderTools(q)
            @loadQuery(q)

          promise.fail (xhr, err, msg) =>
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
            @toolbar = new intermine.query.tools.Tools(q)
            @toolbar.render().$el.appendTo tools

        renderQueryManagement: (q) ->
          managementGroup = new intermine.query.tools.ManagementTools(q, @columnHeaders)
          managementGroup.render().$el.appendTo @tools
          trail = new intermine.query.tools.Trail(q, @)
          trail.render().$el.appendTo managementGroup.el

    class CompactView extends DashBoard

        className: "im-query-display compact"

        TABLE_CLASSES: "im-query-results"

        renderTools: (q) ->
          @toolbar = new intermine.query.tools.ToolBar(q)
          @tools.append @toolbar.render().el

    scope "intermine.query.results", {DashBoard, CompactView}
