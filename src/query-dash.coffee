do ->

    class DashBoard extends Backbone.View
        tagName: "div"
        className: "query-display row-fluid"

        initialize: (service, @query, @queryEvents, @tableProperties) ->
          @columnHeaders = new Backbone.Collection
          @states = new intermine.models.table.History
          @events ?= {}
          if _(service).isString()
            @service = new intermine.Service root: service
          else if service.fetchModel?
            ## Is premade for us.
            @service = service
          else
            @service = new intermine.Service service
          @states.on 'reverted add', =>
            @loadQuery @states.currentQuery

        TABLE_CLASSES: "span9 im-query-results"

        loadQuery: (q) ->
          currentPageSize = @table?.getCurrentPageSize()
          @table?.remove()
          @main.empty()
          @table = new intermine.query.results.Table(q, @main, @columnHeaders)
          @table[k] = v for k, v of @tableProperties
          @table.pageSize = currentPageSize if currentPageSize?
          @table.render()
          q.on evt, cb for evt, cb of @queryEvents

        render: ->
          @$el.addClass intermine.options.StylePrefix
          @tools = $ """<div class="clearfix">"""
          @$el.append @tools
          @main = $ """<div class="#{ @TABLE_CLASSES }">"""
          @$el.append @main

          queryPromise = @service.query @query

          queryPromise.done (q) => @states.addStep 'Original state', q
          
          queryPromise.done (q) =>

           @renderQueryManagement(q)
           @renderTools(q)

          queryPromise.fail (xhr, err, msg) =>
            @$el.append """
              <div class="alert alert-error">
                <h1>#{err or xhr}</h1>
                <p>Unable to construct query: #{msg or xhr}</p>
              </div>
            """

          this

        renderTools: (q) ->
            tools = @make "div", {class: "span3 im-query-toolbox"}
            @$el.append tools
            @toolbar = new intermine.query.tools.Tools @states
            @toolbar.render().$el.appendTo tools

        renderQueryManagement: (q) ->
          {ManagementTools, Trail} = intermine.query.tools
          managementGroup = new ManagementTools(@states, @columnHeaders)
          managementGroup.render().$el.appendTo @tools
          trail = new Trail(@states)
          trail.render().$el.appendTo managementGroup.el

    class CompactView extends DashBoard

        className: "im-query-display compact"

        TABLE_CLASSES: "im-query-results"

        renderTools: (q) ->
          @toolbar = new intermine.query.tools.ToolBar @states
          @tools.append @toolbar.render().el

    scope "intermine.query.results", {DashBoard, CompactView}
