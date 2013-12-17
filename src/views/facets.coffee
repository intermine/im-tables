Backbone = require 'backbone'

{ColumnSummary} = require '../column-summary'

## TODO: Make this information received from a server side call
FACETS =
    Gene: [
        {title: "Pathways",        path: "pathways.name"},
        {title: "Expression Term", path: "mRNAExpressionResults.mRNAExpressionTerms.name"},
        {title: "Ontology Term",   path: "ontologyAnnotations.ontologyTerm.name"},
        {title: "Protein Domains", path: "proteins.proteinDomains.name"}
    ]

class exports.Facets extends Backbone.View
    className: "im-query-facets"
    tagName: "dl"

    initialize: (@query) ->
        # TODO: make more fine-grained responses - don't just redraw everything...
        @query.on "change:constraints", @render
        @query.on "change:joins", @render

    render: =>
        @$el.empty()
        simplify = (x) -> x.replace(/^[^\.]+\./, "").replace(/\./g, " > ")
        facets = (FACETS[@query.root] or []).concat ({title: simplify(v), path: v} for v in @query.views)
        if facets
            searcher = @make "input",
                class: "input-long",
                placeholder: "Filter facets..."
            $(searcher).appendTo(@el).keyup (e) =>
                pattern = new RegExp $(e.target).val(), "i"
                ## TODO: have facets respond to this event
                @query.trigger "filter:facets", pattern

            for f in facets
                cs = new ColumnSummary(f, @query)
                @$el.append cs.el
                cs.render()

        this
