do ->
    class ManagementTools extends Backbone.View

        initialize: (@query) ->
            @query.on "change:constraints", @checkHasFilters, @

        checkHasFilters: () ->
            @$('.im-filters').toggleClass "im-has-constraint", @query.constraints.length > 0

        tagName: "div"
        className: "im-management-tools btn-group"

        html: """
            <button class="btn btn-large im-columns">
                <i class="#{ intermine.icons.Columns }"></i>
                <span class="im-only-widescreen">Manage </span>
                <span class="hidden-tablet">Columns</span>
            </button>
            <button class="btn btn-large im-filters">
                <i class="#{ intermine.icons.Filter }"></i>
                <span class="im-only-widescreen">Manage </span>
                <span class="hidden-tablet">Filters</span>
            </button>
        """

        events:
            'click .im-columns': 'showColumnDialogue'
            'click .im-filters': 'showFilterDialogue'

        showColumnDialogue: (e) ->
            dialogue = new intermine.query.results.table.ColumnsDialogue(@query)
            @$el.append dialogue.el
            dialogue.render().showModal()

        showFilterDialogue: (e) ->
            dialogue = new intermine.query.filters.FilterManager(@query)
            @$el.append dialogue.el
            dialogue.render().showModal()


        render: () ->
            @$el.append @html
            @checkHasFilters()
            this

    scope 'intermine.query.tools', {ManagementTools}
