$ = require 'jquery'

intermine = require 'imjs'

options = require '../options'

OnlyOne = require '../templates/only-one'
Facet = require '../templates/facet'
MoreFacets = require '../templates/more-facets'
{FacetView} = require './facet-view'
BooleanFacet = require './facets/boolean'
PieFacet = require './facets/pie'
HistoFacet = require './facets/histogram'

class exports.FrequencyFacet extends FacetView

    showMore: (e) =>
      more = $ e.target
      got = @$('dd').length()
      areVisible = @$('dd').first().is ':visible'

      e.stopPropagation()
      e.preventDefault()

      @query.summarise @facet.path, (items) =>
        @addItem(item).toggle(areVisible) for item in items[got..]
        more.tooltip('hide').remove()

    render: (filterTerm = "") ->
        return if @rendering
        @filterTerm = filterTerm
        @rendering = true
        @$el.empty()
        super()
        $progress = $ """
          <div class="progress progress-info progress-striped active">
              <div class="bar" style="width:100%"></div>
          </div>
        """
        $progress.appendTo @el
        getSummary = @query.filterSummary @facet.path, filterTerm, @limit
        getSummary.fail @remove
        limit = @limit
        placement = 'left'
        getSummary.done (results, stats, count) =>
          @query.trigger 'got:summary:total', @facet.path, stats.uniqueValues, results.length, count
          $progress.remove()
          @$('.im-facet-count').text("(#{stats.uniqueValues})")
          hasMore = if results.length < limit then false else (stats.uniqueValues > limit)
          if hasMore
            $(MoreFacets).appendTo(@$dt).tooltip({placement}).click @showMore
          
          summaryView = if stats.uniqueValues <= 1
            @$el.empty()
            if stats.uniqueValues then (OnlyOne results[0]) else "No results"
          else
            Vizualization = @getVizualization(stats)
            new Vizualization(@query, @facet, results, hasMore, filterTerm)

          # The facets need appending before rendering so that they calculate their
          # dimensions correctly.
          @$el.append if summaryView.el then summaryView.el else summaryView
          summaryView.render?()

          @rendering = false
          @trigger 'ready', @
    
    getVizualization: (stats) ->
      unless @query.canHaveMultipleValues @facet.path
        if @query.getType(@facet.path) in intermine.Model.BOOLEAN_TYPES
          return BooleanFacet
        else if stats.uniqueValues <= options.MAX_PIE_SLICES
          return PieFacet
      return HistoFacet

    addItem: (item) =>
        $dd = $(Facet(item)).appendTo @el
        $dd.click =>
            @query.addConstraint
                title: @facet.title
                path: @facet.path
                op: "="
                value: item.item
        $dd
