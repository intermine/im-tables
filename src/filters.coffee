scope "intermine.messages.filters", {
    AddNew: "Add Filter",
    DefineNew: 'Define a new filter',
    EditOrRemove: 'edit or remove the currently active filters',
    None: 'No active filters',
    Heading: "Active Filters"
}

scope "intermine.css", {
  FilterBoxClass: 'well' # alert alert-info
}

do ->

    class Filters extends Backbone.View
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

        className: "im-constraints"

        initialize: (@query) ->
            @query.on "change:constraints", @render

        getConstraints: -> @query.constraints

        getConAdder: -> new intermine.query.ConstraintAdder(@query)

        render: =>
            cons = @getConstraints()
            msgs = intermine.messages.filters

            @$el.empty()
            @$el.append(@make "h3", {}, msgs.Heading)
            conBox = $ """<div class="#{ intermine.css.FilterBoxClass }">"""
            conBox.appendTo(@el)
              .append(@make "p",  {class: 'well-help'}, if cons.length then msgs.EditOrRemove else msgs.None)
              .append(ul = @make "ul", {})

            for c in cons then do (c) =>
                con = new intermine.query.ActiveConstraint(@query, c)
                con.render().$el.appendTo $ ul

            @getConAdder()?.render().$el.appendTo @el

            this

        events:
            click: (e) -> e.stopPropagation()

    class FilterManager extends Constraints
        className: "im-filter-manager modal fade"
        tagName: "div"

        initialize: (@query) ->
            @query.on 'change:constraints', () => @hideModal()

        html: """
           <div class="modal-header">
               <a href="#" class="close im-closer">close</a>
               <h3>#{ intermine.messages.filters.Heading }</h3>
           </div>
           <div class="modal-body">
               <div class="#{ intermine.css.FilterBoxClass }">
                   <p class="well-help"></p>
                   <ul></ul>
               </div>
               <button class="btn im-closer im-define-new-filter">
                   #{ intermine.messages.filters.DefineNew }
               </button>
           </div>
        """

        events:
            'hidden': 'remove'
            'click .icon-remove-sign': 'hideModal'
            'click .im-closer': 'hideModal'
            'click .im-define-new-filter': 'addNewFilter'

        addNewFilter: (e) -> @query.trigger 'add-filter-dialogue:please'

        hideModal: (e) ->
            @$el.modal 'hide'
            # Horrible, horrible hackity hack, making kittens cry.
            $('.modal-backdrop').trigger 'click'

        showModal: () -> @$el.modal().modal 'show' 

        render: () ->
            @$el.append @html
            cons = @getConstraints()
            msgs = intermine.messages.filters

            @$('.well-help').append if cons.length then msgs.EditOrRemove else msgs.None
            ul = @$ 'ul'

            for c in cons then do (c) =>
                con = new intermine.query.ActiveConstraint(@query, c)
                con.render().$el.appendTo ul
            
            @
            

    class SingleConstraintAdder extends intermine.query.ConstraintAdder

        initialize: (query, @view) ->
            super(query)
            @query.on 'cancel:add-constraint', => # Reset add button to appropriate state.
                @$('.btn-primary').toggle @getTreeRoot().isAttribute()

        initPaths: -> [@view]

        getTreeRoot: () -> @query.getPathInfo(@view)

        render: ->
            super()
            @$('input').remove()
            root = @getTreeRoot()
            console.log @view
            if root.isAttribute()
                @chosen = root
                @$('button.btn-primary').text(intermine.messages.filters.DefineNew).attr disabled: false
                @$('button.btn-chooser').remove()
            this
    
    class SingleColumnConstraints extends Constraints
        initialize: (query, @view) -> super(query)

        getConAdder: -> new SingleConstraintAdder(@query, @view)

        getConstraints: -> c for c in @query.constraints when (c.path.match @view)

    class SingleColumnConstraintsSummary extends SingleColumnConstraints
        getConAdder: ->

        render: ->
            super()
            cons = @getConstraints()
            if cons.length < 1
                @undelegateEvents()
                @$el.hide()
            this

    
    scope "intermine.query.filters", {SingleColumnConstraintsSummary, SingleColumnConstraints, Filters, FilterManager}
