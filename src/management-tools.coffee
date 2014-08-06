do ->
    class ManagementTools extends Backbone.View

        initialize: (@states, @columnHeaders) ->
          @states.on 'add reverted', @checkHasFilters, @
          intermine.onChangeOption 'Style.icons', @render, @

        checkHasFilters: () ->
          if q = @states.currentQuery
            count = q.constraints.length
            @$('.im-filters').toggleClass "im-has-constraint", count > 0
            @$('.im-filters .im-action').text if count > 0 then count else 'Add '

        tagName: "div"
        className: "im-management-tools"

        html: -> """
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
          q = @states.currentQuery
          dialogue = new intermine.query.results.table.ColumnsDialogue(q, @columnHeaders)
          @$el.append dialogue.el
          dialogue.render().showModal()

        showFilterDialogue: (e) ->
          q = @states.currentQuery
          dialogue = new intermine.query.filters.FilterManager(q)
          @$el.append dialogue.el
          dialogue.render().showModal()

        render: () ->
            @$el.html @html()
            @checkHasFilters()
            this

    scope 'intermine.query.tools', {ManagementTools}
