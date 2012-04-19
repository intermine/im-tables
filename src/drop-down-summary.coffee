scope "intermine.query.results", (exporting) ->

    exporting class DropDownColumnSummary extends Backbone.View
        className: "im-dropdown-summary"

        initialize: (@view, @query) ->

        render: ->
            cons = new intermine.query.filters.SingleColumnConstraints(@query, @view)
            cons.render().$el.appendTo @el

            summ = new intermine.results.ColumnSummary(@view, @query)
            summ.render().$el.appendTo @el

            summ.$('dt').remove()
            this








        
