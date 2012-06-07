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
            summ.noTitle = true
            summ.render().$el.appendTo @el

            this

    class SummaryHeading extends Backbone.View

        initialize: (@query, @view) ->
            @query.on "got:summary:total", (path, total, got, filteredTotal) =>
                if path is @view
                    nts = (num) -> intermine.utils.numToString(num, ',', 3)
                    available = filteredTotal ? total
                    @$('.im-item-available').text nts available
                    @$('.im-item-got').text(if got is available then 'All' else "#{ nts(got) } of"  )
                    @$('.im-item-total').text(if filteredTotal? then "(filtered from #{ nts total })" else "")


        template: _.template """
            <h3>
                <span class="im-item-got"></span>
                <span class="im-item-available"></span>
                <span class="im-type-name"></span>
                <span class="im-attr-name"></span>
                <span class="im-item-total"></span>
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


        
