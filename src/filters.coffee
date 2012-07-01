scope "intermine.query.filters", (exporting) ->

    exporting class Filters extends Backbone.View
        className: "im-query-filters"

        initialize: (@query) ->

        render: ->
            constraints = new Constraints(@query)
            constraints.render().$el.appendTo @el

            facets = new Facets(@query)
            facets.render().$el.appendTo @el

            this

    ## TODO: Make this information received from a server side call
    FACETS =
        Gene: [
            {title: "Pathways",        path: "pathways.name"},
            {title: "Expression Term", path: "mRNAExpressionResults.mRNAExpressionTerms.name"},
            {title: "Ontology Term",   path: "ontologyAnnotations.ontologyTerm.name"},
            {title: "Protein Domains", path: "proteins.proteinDomains.name"}
        ]

    class Facets extends Backbone.View
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
                searcher = @make "input"
                    class: "input-long",
                    placeholder: "Filter facets..."
                $(searcher).appendTo(@el).keyup (e) =>
                    pattern = new RegExp $(e.target).val(), "i"
                    ## TODO: have facets respond to this event
                    @query.trigger "filter:facets", pattern

                for f in facets
                    cs = new intermine.results.ColumnSummary(f, @query)
                    @$el.append cs.el
                    cs.render()

            this

    class Constraints extends Backbone.View

        className: "alert alert-info im-constraints"

        initialize: (@query) ->
            @query.on "change:constraints", @render

        getConstraints: -> @query.constraints

        getConAdder: -> new intermine.query.ConstraintAdder(@query)

        render: =>
            cons = @getConstraints()

            @$el.empty()
            @$el.append(@make "h3", {}, "Active Filters")
                .append(@make "p",  {},
                    if cons.length then "edit or remove the currently active filters" else "No filters")
                .append(ul = @make "ul", {})

            for c in cons then do (c) =>
                con = new intermine.query.ActiveConstraint(@query, c)
                con.render().$el.appendTo $ ul

            @getConAdder()?.render().$el.appendTo @el

            this

        events:
            click: (e) -> e.stopPropagation()
            

    class SingleConstraintAdder extends intermine.query.ConstraintAdder

        initialize: (query, @view) -> super(query)

        initPaths: -> [@view]

        render: ->
            super()
            @$('input').remove()
            @$('button[type=submit]').attr disabled: false
            @$el.append """<input type="hidden" value="#{ @view }">"""
            this
    
    exporting class SingleColumnConstraints extends Constraints
        initialize: (query, @view) -> super(query)

        getConAdder: -> new SingleConstraintAdder(@query, @view)

        getConstraints: -> c for c in @query.constraints when (c.path.match @view)

    exporting class SingleColumnConstraintsSummary extends SingleColumnConstraints
        getConAdder: ->

        render: ->
            super()
            cons = @getConstraints()
            if cons.length < 1
                @undelegateEvents()
                @$el.hide()
            this

    
        



