scope "intermine.query.results", (exporting) ->

    exporting class DropDownColumnSummary extends Backbone.View
        className: "im-dropdown-summary"

        initialize: (@view, @query) ->

        render: ->
            heading = new SummaryHeading(@query, @view)
            heading.render().$el.appendTo @el

            cons = new intermine.query.filters.SingleColumnConstraints(@query, @view)
            cons.render().$el.appendTo @el

            summ = new intermine.results.ColumnSummary(@view, @query)
            summ.render().$el.appendTo @el

            summ.$('dt').remove()
            this

    class SummaryHeading extends Backbone.View

        initialize: (@query, @view) ->
            @query.on "got:summary:total", (path, total, got) =>
                if path is @view
                    @$('.im-item-count').text(intermine.utils.numToString(total, ",", 3))
                    @$('.im-item-got').text(if got is total then 'All' else got)


        template: _.template """
            <h3>
                <span class="im-item-got"></span>
                of
                <span class="im-item-count"></span>
                <span class="im-type-name"></span>
                <span class="im-attr-name"></span>
            </h3>
        """

        render: ->
            @$el.append @template()

            s = @query.service
            type = @query.getPathInfo(@view).getParent().getType().name
            attr = @query.getPathInfo(@view).end.name

            s.makeRequest "model/#{type}", {}, (info) =>
                @$('.im-type-name').text info.name

            s.makeRequest "model/#{type}/#{attr}", {}, (info) =>
                @$('.im-attr-name').text intermine.utils.pluralise(info.name)

            this


        
