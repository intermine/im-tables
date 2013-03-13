do ->
    class ManagementTools extends Backbone.View

        initialize: (@query, @columnHeaders) ->
          @query.on "change:constraints", @checkHasFilters, @
          @query.on 'revert', (state) =>
            newQ = state.get 'query'
            delete @query
            @$el.empty()
            @initialize newQ, @columnHeaders
            @render()

        checkHasFilters: () ->
          count = @query.constraints.length
          @$('.im-filters').toggleClass "im-has-constraint", count > 0
          @$('.im-filters .im-action').text if count > 0 then count else 'Add '

        tagName: "div"
        className: "im-management-tools"

        html: """
          <div class="btn-group"> 
            <button class="btn im-columns">
                <i class="#{ intermine.icons.Columns }"></i>
                <span class="im-only-widescreen">Manage </span>
                <span class="hidden-tablet">Columns</span>
            </button>
            <button class="btn im-filters">
                <i class="#{ intermine.icons.Filter }"></i>
                <span class="hidden-phone im-action">Manage </span>
                <span class="hidden-phone">Filters</span>
            </button>
          </div>
        """

        events:
            'click .im-columns': 'showColumnDialogue'
            'click .im-filters': 'showFilterDialogue'

        showColumnDialogue: (e) ->
            dialogue = new intermine.query.results.table.ColumnsDialogue(@query, @columnHeaders)
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
