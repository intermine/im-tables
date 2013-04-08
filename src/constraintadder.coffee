scope 'intermine.messages.constraints',
  BrowseForColumn: 'Browse for Column'
  AddANewFilter: 'Add a new filter'
  Filter: 'Filter'

do ->
  
    pos = (substr) -> _.memoize (str) -> str.toLowerCase().indexOf substr
    pathLen = _.memoize (str) -> str.split(".").length

    CONSTRAINT_ADDER_HTML = """
      <input type="text" placeholder="#{ intermine.messages.constraints.AddANewFilter }"
              class="im-constraint-adder span9">
      <button disabled class="btn btn-primary span2" type="submit">
        #{ intermine.messages.constraints.Filter }
      </button>
    """

    PATH_LEN_SORTER = (items) ->
        getPos = pos @query.toLowerCase()
        items.sort (a, b) ->
            if a is b
                0
            else
                getPos(a) - getPos(b) || pathLen(a) - pathLen(b) || if a < b then -1 else 1
        return items

    PATH_MATCHER = (item) ->
        lci = item.toLowerCase()
        terms = (term for term in @query.toLowerCase().split(/\s+/) when term)
        item and _.all terms, (t) -> lci.match(t)

    PATH_HIGHLIGHTER = (item) ->
        terms = @query.toLowerCase().split(/\s+/)
        for term in terms when term
            item = item.replace new RegExp(term, "gi"), (match) -> "<>#{ match }</>"
        item.replace(/>/g, "strong>")

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
                a = $ @template _.extend {}, @, name: name, path: @path, type: @path.getType()
                a.appendTo(@el)
                @addedLiContent(a)
            this

        addedLiContent: (a) ->
            if intermine.options.ShowId
                a.tooltip(placement: 'bottom').appendTo @el
            else
                a.attr title: ""

    class RootClass extends Attribute

        className: 'im-rootclass'

        initialize: (@query, @cd, @evts, @multiSelect) ->
            super(@query, @query.getPathInfo(@cd.name), 0, @evts, (() -> false), @multiSelect)

        template: _.template """<a href="#">
              <i class="icon-stop"></i>
              <span><%- name %></span>
            </a>
            """

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
            @evts.on 'collapse:tree-branches', @collapse

        collapse: =>
          @subfinder?.remove()
          @$el.removeClass 'open'
          @$('i.im-has-fields')
            .removeClass(intermine.icons.Expanded)
            .addClass(intermine.icons.Collapsed)

        remove: () ->
          @collapse()
          super()

        openSubFinder: () ->
          @$el.addClass('open')
          @$('i.im-has-fields')
            .addClass(intermine.icons.Expanded)
            .removeClass(intermine.icons.Collapsed)
          @subfinder = new PathChooser(@query, @path, @depth + 1, @evts, @getDisabled, @isSelectable, @multiSelect)
          @subfinder.allowRevRefs @allowRevRefs

          @$el.append @subfinder.render().el

        template: _.template """<a href="#">
              <i class="#{ intermine.icons.Collapsed } im-has-fields"></i>
              <% if (isLoop) { %>
                <i class="#{ intermine.icons.ReverseRef }"></i>
              <% } %>
              <span><%- name %></span>
            </a>
            """

        iconClasses: intermine.icons.ExpandCollapse

        toggleFields: () ->
            if @$el.is '.open'
              @collapse()
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
          prefix = new RegExp "^#{ @path }\\."

          if _.any(@query.views, (v) -> v.match prefix)
            @toggleFields()
            @$el.addClass('im-in-view')

    class ReverseReference extends Reference

        template: _.template """<a href="#">
              <i class="#{ intermine.icons.ReverseRef } im-has-fields"></i>
              <span><%- name %></span>
            </a>
            """

        toggleFields: () -> # no-op

        handleClick: (e) -> 
          e.preventDefault()
          e.stopPropagation()
          @$el.tooltip 'hide'

        render: () ->
            super()
            @$el.attr(title: "Refers back to #{ @path.getParent().getParent() }").tooltip()
            this


    class PathChooser extends Backbone.View
        tagName: 'ul'
        dropDownClasses: '' #'typeahead dropdown-menu'

        searchFor: (terms) =>
            @evts.trigger('filter:paths', terms)
            matches = (p for p in @query.getPossiblePaths(3) when _.all terms, (t) => p.match(new RegExp(t, 'i')))
            for m in matches
                @evts.trigger 'matched', m, terms
            
        initialize: (@query, @path, @depth, events, @getDisabled, @canSelectRefs, @multiSelect) ->
            @state = new Backbone.Model allowRevRefs: false
            @leaves = []
            @evts =  if (@depth is 0) then _.extend({}, Backbone.Events) else events
            cd = @path.getEndClass()
            toPath = (f) => @path.append f
            @attributes = (toPath attr for name, attr of cd.attributes)
            @references = (toPath ref for name, ref of cd.references)
            @collections = (toPath coll for name, coll of cd.collections)
            @evts.on 'chosen', events if @depth is 0
            @on 'collapse:tree-branches', =>
              console.log "Bringing the tree down"
              @evts.trigger 'collapse:tree-branches'
            @state.on 'change:allowRevRefs', =>
              @reset()
              @render()

        allowRevRefs: (allowed) =>
          @state.set allowRevRefs: allowed

        remove: ->
          @evts.off() if @depth is 0
          @state.off()
          super()
                
        reset: ->
          @$root?.remove()
          for leaf in @leaves
            leaf.remove()
          @leaves = []

        render: () ->
          cd = @path.getEndClass()
          if @depth is 0 and @canSelectRefs # then show the root class
            @$root = new RootClass(@query, cd, @evts, @multiSelect)
            @$el.append @$root.render().el
          for apath in @attributes
            if intermine.options.ShowId or apath.end.name isnt 'id'
              attr = new Attribute(@query, apath, @depth, @evts, @getDisabled, @multiSelect)
              @leaves.push attr
              @$el.append(attr.render().el)

          for rpath in @references.concat(@collections)
            isLoop = false
            if rpath.end.reverseReference? and @path.isReference()
              if @path.getParent().isa rpath.end.referencedType
                if @path.end.name is rpath.end.reverseReference
                  isLoop = true

            # TODO. Clean this up with an options constructor.
            if isLoop and not @state.get('allowRevRefs')
                ref = new ReverseReference(@query, rpath, @depth, @evts, (() -> true), @multiSelect, @canSelectRefs)
            else
                ref = new Reference(@query, rpath, @depth, @evts, @getDisabled, @multiSelect, @canSelectRefs)
            ref.allowRevRefs = @state.get('allowRevRefs')
            ref.isLoop = isLoop
            @leaves.push ref
            @$el.append ref.render().el

          @$el.addClass(@dropDownClasses) if @depth is 0
          @$el.show()
          this

    class ConstraintAdder extends Backbone.View

        tagName: "form"
        className: "form im-constraint-adder row-fluid im-constraint"

        initialize: (@query) ->

        events: ->
            'submit': 'handleSubmission'
            'click .im-collapser': 'collapseBranches'
            'change .im-allow-rev-ref': 'allowReverseRefs'

        collapseBranches: ->
          @$pathfinder?.trigger 'collapse:tree-branches'

        allowReverseRefs: ->
          @$pathfinder?.allowRevRefs @$('.im-allow-rev-ref').is(':checked')

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
                con = path: @chosen.toString()

                @newCon = new intermine.query.NewConstraint(@query, con)
                @newCon.render().$el.insertAfter @el
                @$('.btn-primary').fadeOut('fast') # Only add one constraint at a time...
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
            @trigger 'resetting:tree'
            @$pathfinder?.remove()
            @$pathfinder = null
            @$('.im-tree-option').addClass 'hidden'

        showTree: (e) =>
          @$('.im-tree-option').removeClass 'hidden'
          @trigger 'showing:tree'
          if @$pathfinder?
            @reset()
          else
            treeRoot = @getTreeRoot()
            pathFinder = new PathChooser(@query, treeRoot, 0, @handleChoice, @isDisabled, @refsOK, @multiSelect)
            pathFinder.render()
            @$el.append(pathFinder.el)
            pathFinder.$el.show().css top: @$el.height()
            @$pathfinder = pathFinder

        VALUE_OPS =  intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.REFERENCE_OPS)

        isValid: () ->
            if @newCon?
              if not @newCon.con.has('op')
                  return false
              if @newCon.con.get('op') in VALUE_OPS
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
                <span>#{ intermine.messages.constraints.BrowseForColumn }</span>
              </button>
            """

            approver = $ @make 'button', {type: "button", class: "btn btn-primary"}, "Choose"
            @$el.append browser
            @$el.append approver
            approver.click @handleSubmission
            browser.click @showTree
            @$('.btn-chooser').after """
              <label class="im-tree-option hidden">
                #{intermine.messages.columns.AllowRevRef }
                <input type="checkbox" class="im-allow-rev-ref">
              </label>
              <button class="btn im-collapser im-tree-option hidden" type="button" >
                #{ intermine.messages.columns.CollapseAll }
              </button>
            """
            this

    scope "intermine.query", {PATH_LEN_SORTER, PATH_MATCHER, PATH_HIGHLIGHTER, ConstraintAdder}

