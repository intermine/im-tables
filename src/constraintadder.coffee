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

            unless @getDisabled(@path)
                isNewChoice = not @$el.is '.active'
                @evts.trigger 'chosen', @path, isNewChoice

        initialize: (@query, @path, @depth, @evts, @getDisabled, @multiSelect) ->
            @evts.on 'remove', () => @remove()
            @evts.on 'chosen', (p, isNewChoice) =>
                if (p.toString() is @path.toString())
                    @$el.toggleClass('active', isNewChoice)
                else
                    @$el.removeClass('active') unless @multiSelect

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
            disabled = @getDisabled(@path)
            @$el.addClass('disabled') if disabled
            @path.getDisplayName (name) =>
                @displayName = name
                name = name.replace(/^.*\s*>/, '') # unless @depth is 0
                a = $ @template name: name, path: @path, type: @path.getType()
                a.appendTo(@el)
                @addedLiContent(a)
            this

        addedLiContent: (a) ->
            if intermine.options.ShowId
                a.tooltip(placement: 'bottom').appendTo @el
            else
                a.attr title: ""

    class Reference extends Attribute

        initialize: (@query, @path, @depth, @evts, @getDisabled, @multiSelect, @isSelectable) ->
            super(@query, @path, @depth, @evts, @getDisabled, @multiSelect)

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
            @subfinder = new PathChooser(@query, @path, @depth + 1, @evts, @getDisabled, @isSelectable, @multiSelect)
            @$el.append @subfinder.render().el
            @$el.addClass('open')

        template: _.template """<a href="#">
              <i class="icon-chevron-right im-has-fields"></i>
              <span><%- name %></span>
            </a>
            """

        iconClasses: """icon-chevron-right icon-chevron-down"""

        toggleFields: () ->
            @$el.children().filter('i.im-has-fields').toggleClass @iconClasses
            if @$el.is '.open'
                @$el.removeClass('open').children('ul').remove()
            else
                @openSubFinder()

        handleClick: (e) ->
            e.preventDefault()
            e.stopPropagation()
            if $(e.target).is('.im-has-fields') or (not @isSelectable)
                @toggleFields()
            else
                super(e)

        addedLiContent: (a) ->
            if _.any(@query.views, (v) => v.match(@path.toString()))
                @openSubFinder()

    class ReverseReference extends Reference

        template: _.template """<a href="#">
              <i class="icon-retweet im-has-fields"></i>
              <span><%- name %></span>
            </a>
            """

        toggleFields: () -> # no-op

        handleClick: () -> # no-op

        render: () ->
            super()
            @$el.attr(title: "Refers back to #{ @path.getParent().getParent() }").tooltip()
            this


    class PathChooser extends Backbone.View
        tagName: 'ul'
        dropDownClasses: 'typeahead dropdown-menu'

        searchFor: (terms) =>
            @evts.trigger('filter:paths', terms)
            matches = (p for p in @query.getPossiblePaths(3) when _.all terms, (t) => p.match(new RegExp(t, 'i')))
            for m in matches
                @evts.trigger 'matched', m, terms
            
        initialize: (@query, @path, @depth, events, @getDisabled, @canSelectRefs, @multiSelect) ->
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
            for apath in @attributes
                if intermine.options.ShowId or apath.end.name isnt 'id'
                    @$el.append(new Attribute(@query, apath, @depth, @evts, @getDisabled, @multiSelect).render().el)
            @$el.append PathChooser.DIVIDER
            for rpath in @references.concat(@collections)
                isLoop = false
                if rpath.end.reverseReference? and @path.isReference()
                    if @path.getParent().isa rpath.end.referencedType
                        if @path.end.name is rpath.end.reverseReference
                            isLoop = true

                if isLoop
                    ref = new ReverseReference(@query, rpath, @depth, @evts, (() -> true), @multiSelect, @canSelectRefs)
                else
                    ref = new Reference(@query, rpath, @depth, @evts, @getDisabled, @multiSelect, @canSelectRefs)
                @$el.append ref.render().el

            @$el.addClass(@dropDownClasses) if @depth is 0
            @$el.show()
            this

    exporting class ConstraintAdder extends Backbone.View

        tagName: "form"
        className: "form im-constraint-adder row-fluid im-constraint"

        initialize: (@query) ->

        events:
            'submit': 'handleSubmission'

        handleClick: (e) ->
            e.preventDefault()
            unless $(e.target).is 'button'
                e.stopPropagation()
            if $(e.target).is 'button.btn-primary'
                @handleSubmission(e)

        handleSubmission: (e) =>
            e.preventDefault()
            e.stopPropagation()
            if @chosen?
                con =
                    path: @chosen.toString()

                @newCon = new intermine.query.NewConstraint(@query, con)
                @newCon.render().$el.insertAfter @el
                @$('.btn-primary').fadeOut('slow') # Only add one constraint at a time...
                @$pathfinder?.remove()
                @$pathfinder = null
                @query.trigger 'editing-constraint'
            else
                console.log "Nothing chosen"

        handleChoice: (path, isNewChoice) =>
            if isNewChoice
                @chosen = path
                @$('.btn-primary').fadeIn('slow')
            else
                @chosen = null
                @$('.btn-primary').fadeOut('slow')

        isDisabled: (path) -> false

        getTreeRoot: () -> @query.getPathInfo(@query.root)

        refsOK: true
        multiSelect: false
        reset: () ->
            @$pathfinder.remove()
            @$pathfinder = null

        showTree: (e) =>
            if @$pathfinder?
                @reset()
            else
                root = @getTreeRoot()
                pathFinder = new PathChooser(@query, root, 0, @handleChoice, @isDisabled, @refsOK, @multiSelect)
                pathFinder.render().$el.appendTo(@el).show()
                pathFinder.$el.css top: @$el.height()
                @$pathfinder = pathFinder

        isValid: () ->
            if @newCon?
                if not @newCon.con.has('op')
                    return false
                if @newCon.con.get('op') in intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.REFERENCE_OPS)
                    return @newCon.con.has('value')
                if @newCon.con.get('op') in intermine.Query.MULTIVALUE_OPS
                    return @newCon.con.has('values')
                return true
            else
                return false

        render: ->
            browser = $ """
                    <button type="button" class="btn btn-chooser" data-toggle="button">
                        <i class="icon-sitemap"></i>
                        Browse for column
                    </button>
                """

            approver = $ @make 'button', {type: "button", class: "btn btn-primary"}, "Choose"
            @$el.append browser
            @$el.append approver
            approver.click @handleSubmission
            browser.click @showTree
            this

