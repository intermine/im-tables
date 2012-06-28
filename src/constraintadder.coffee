scope "intermine.query", (exporting) ->

    pos = (substr) -> _.memoize (str) -> str.toLowerCase().indexOf substr
    pathLen = _.memoize (str) -> str.split(".").length

    exporting PATH_LEN_SORTER = (items) ->
        getPos = pos @query.toLowerCase()
        items.sort (a, b) ->
            if a is b
                0
            else
                getPos(a) - getPos(b) || pathLen(a) - pathLen(b) || if a < b then -1 else 1
        return items

    exporting PATH_MATCHER = (item) ->
        lci = item.toLowerCase()
        terms = (term for term in @query.toLowerCase().split(/\s+/) when term)
        item and _.all terms, (t) -> lci.match(t)

    exporting PATH_HIGHLIGHTER = (item) ->
        terms = @query.toLowerCase().split(/\s+/)
        for term in terms when term
            item = item.replace new RegExp(term, "gi"), (match) -> "<>#{ match }</>"
        item.replace(/>/g, "strong>")

    CONSTRAINT_ADDER_HTML = """
        <input type="text" placeholder="Add a new filter" class="im-constraint-adder span9">
        <button disabled class="btn span2" type="submit">
            Filter
        </button>
    """

    class Attribute extends Backbone.View
        tagName: 'li'

        events:
            'click a': 'handleClick'

        handleClick: (e) ->
            e.stopPropagation()
            e.preventDefault()
            @evts.trigger 'chosen', @path

        initialize: (@query, @path, @depth, @evts) ->
            @evts.on 'remove', () => @remove()
            @evts.on 'filter:paths', (terms) =>
                terms = (new RegExp(t, 'i') for t in terms when t)
                if terms.length
                    matches = 0
                    lastMatch = null
                    for t in terms
                        if (t.test(@path.toString()) || t.test(@displayName))
                            matches += 1
                            lastMatch = t
                    @matches(matches, terms, lastMatch)
                else
                    @$el.show()

        template: _.template """<a href="#" title="<%- path %> (<%- type %>)"><span><%- name %></span></a>"""

        matches: (matches, terms) ->
            if matches is terms.length
                @evts.trigger 'matched', @path.toString()
                @path.getDisplayName (name) =>
                    hl = if (@depth > 0) then name.replace(/^.*>\s*/, '') else name
                    for term in terms
                        hl = hl.replace term, (match) -> "<strong>#{ match }</strong>"
                    matchesOnPath = _.any terms, (t) => !!@path.end.name.match(t)
                    @$('a span').html if (hl.match(/strong/) or not matchesOnPath) then hl else "<strong>#{ hl }</strong>"
            @$el.toggle !!(matches is terms.length)
    
        render: () ->
            disabled = (@path.toString() in @query.views)
            @$el.addClass('disabled') if disabled
            @path.getDisplayName (name) =>
                @displayName = name
                name = name.replace(/^.*\s*>/, '') unless @depth is 0
                a = $ @template name: name, path: @path, type: @path.getType()
                a.appendTo(@el)
                @addedLiContent(a)
            this

        addedLiContent: (a) ->
            a.tooltip(placement: 'bottom').appendTo @el

    class Reference extends Attribute

        initialize: (@query, @path, @depth, @evts) ->
            super(@query, @path, @depth, @evts)

            @evts.on 'filter:paths', (terms) =>
                @$el.hide()
            @evts.on 'matched', (path) =>
                if path.match(@path.toString())
                    @$el.show()
                    unless @$el.is '.open'
                        @openSubFinder()

        remove: () ->
            @subfinder?.remove()
            super()

        openSubFinder: () ->
            @subfinder = new PathChooser(@query, @path, @depth + 1, @evts)
            @$el.append @subfinder.render().el
            @$el.addClass('open')

        template: _.template """<a href="#"><i class="icon-chevron-right"></i> <span><%- name %></span></a>"""

        iconClasses: """icon-chevron-right icon-chevron-down"""

        addedLiContent: (a) ->
            if _.any(@query.views, (v) => v.match(@path.toString()))
                @openSubFinder()

            i = a.find('i').click (e) =>
                i.toggleClass @iconClasses
                if @$el.is '.open'
                    @$el.removeClass('open').children('ul').remove()
                else
                    @openSubFinder()
            

    class PathChooser extends Backbone.View
        tagName: 'ul'
        dropDownClasses: 'typeahead dropdown-menu'

        searchFor: (terms) =>
            @evts.trigger('filter:paths', terms)
            matches = (p for p in @query.getPossiblePaths(3) when _.all terms, (t) => p.match(new RegExp(t, 'i')))
            for m in matches
                @evts.trigger 'matched', m, terms
            
        initialize: (@query, @path, @depth, events) ->
            @evts =  if (@depth is 0) then _.extend({}, Backbone.Events) else events
            cd = @path.getEndClass()
            toPath = (f) => @path.append f
            @attributes = (toPath attr for name, attr of cd.attributes)
            @references = (toPath ref for name, ref of cd.references)
            @collections = (toPath coll for name, coll of cd.collections)
            @evts.on 'chosen', events if @depth is 0
                
        @DIVIDER: """<li class="divider"></li>"""

        render: () ->
            cd = @path.getEndClass()
            currentView = @query.views
            for apath in @attributes
                @$el.append(new Attribute(@query, apath, @depth, @evts).render().el)
            @$el.append PathChooser.DIVIDER
            for rpath in @references
                @$el.append(new Reference(@query, rpath, @depth, @evts).render().el)
            for cpath in @collections
                @$el.append(new Reference(@query, cpath, @depth, @evts).render().el)

            @$el.addClass(@dropDownClasses) if @depth is 0
            @$el.show()
            this
            

    exporting class ConstraintAdder extends Backbone.View

        tagName: "form"
        className: "form im-constraint-adder row-fluid im-constraint"

        initialize: (@query) ->
            @query.on "cancel:add-constraint", =>
                @$('input').show()
                @$('button[type="submit"]').show()

        events:
            'submit': 'handleSubmission'

        handleKeyup: (e) -> $('.btn-primary').attr disabled: false

        leaveSearch: (e) ->
            emptySearchBox = ->
                $('input').val('')
                $('.btn-primary').attr disabled: true
            _.delay emptySearchBox, 7000

        handleClick: (e) ->
            e.preventDefault()
            unless $(e.target).is 'button'
                e.stopPropagation()
            if $(e.target).is 'button[type="submit"]'
                @handleSubmission(e)

        handleSubmission: (e) ->
            e.preventDefault()
            e.stopPropagation()
            @$('input').hide()
            @$('button[type="submit"]').hide()
            con =
                path: @$('input').val()

            ac = new intermine.query.NewConstraint(@query, con)
            ac.render().$el.appendTo @el

        handleChoice: (path) =>
            @$('input').val(path.toString())
            @$('.btn-primary').attr disabled: false

        showTree: (e) =>
            e.stopPropagation()
            e.preventDefault()
            if @$pathfinder
                @$pathfinder.remove()
                @$pathfinder = null
            else
                root = @query.getPathInfo(@query.root)
                pathFinder = new PathChooser(@query, root, 0, @handleChoice)
                pathFinder.render().$el.appendTo(@el).show()
                #pathFinder.$el.offset left: @$el.offset().left, top:  @$el.offset().top + @$el.height()
                pathFinder.$el.css top: @$el.height()
                @$pathfinder = pathFinder

        showOptions: () ->

        filterOptions: (e) =>
            return false if @filterLock
            @filterLock = true
            @showTree(e) unless @$pathfinder?
            val = @$('input').val()?.replace(/\s+$/g, '').replace(/^\s+/g, '')
            if val?
                @$('.btn-primary').attr disabled: false
            if val? and val.length >= 3
                # Handle our own throttling...
                thisTime = new Date().getTime()

                if (not @lastSearch?) or ((@lastSearch.time + 1000 < thisTime) and (@lastSearch.term isnt val))
                    if @lastSearch?
                        @$pathfinder.remove()
                        @$pathfinder = null
                        @showTree(e)
                    console.log "Searching for #{ val } at #{ thisTime }"
                    @lastSearch = time: thisTime, term: val
                    terms = (val?.split(/\s+/) || [])
                    @$pathfinder?.searchFor(terms)
                else
                    console.log "No search needed at #{ thisTime }"
            @filterLock = false

        inputPlaceholder: "Add a column..."

        render: ->
            input = @make "input",
                type: "text",
                placeholder: @inputPlaceholder
            @$el.append input
            browser = $ @make 'button', {type: "button", class: "btn"}, "Browse"
            approver = $ @make 'button', {type: "button", class: "btn btn-primary", disabled: true}, "Add"
            @$el.append browser
            @$el.append approver
            approver.click @handleSubmission
            browser.click @showTree
            @$('input').click(@showOptions).keyup(@filterOptions)
            this

