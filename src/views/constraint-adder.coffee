_ = require 'underscore'

Messages = require '../messages'
Icons = require '../icons'
View = require '../core-view'
# FIXME - make this import work
NewConstraint = require './new-constraint'

{Query} = require 'imjs'

Messages.set
  'constraints.BrowseForColumn': 'Browse for Column'
  'constraints.AddANewFilter': 'Add a new filter'
  'constraints.Filter': 'Filter'

pos = (substr) -> _.memoize (str) -> str.toLowerCase().indexOf substr
pathLen = _.memoize (str) -> str.split(".").length

# FIXME Needs to be wrapped in a function
CONSTRAINT_ADDER_HTML = _.template """
  <input type="text"
         placeholder="<%= messages.getText('constraints.AddANewFilter') %>"
         class="im-constraint-adder span9">
  <button disabled class="btn btn-primary span2" type="submit">
    <%= messages.getText('constraints.Filter') %>
  </button>
"""

# UI - autocomplete passes the query as this.
# FIXME - make sure ui autocomplete is loaded.
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

# FIXME - Replace events with a model (TreeModel?) that
# keeps track of what paths are expanded, and what the current
# filter term is.
# Other things like rev-refs can be put in there also.

class Attribute extends View
  tagName: 'li'

  events:
      'click a': 'handleClick'

  handleClick: (e) ->
    e.stopPropagation()
    e.preventDefault()

    unless @getDisabled(@path)
      isNewChoice = not @$el.is '.active'
      @evts.trigger 'chosen', @path, isNewChoice

  initialize: ->
    super
    # (@query, @path, @depth, @evts, @getDisabled, @multiSelect) ->
    @listenTo @evts, 'remove', @remove
    @listenTo @evts, 'chosen', (p, isNewChoice) =>
      if (p.toString() is @path.toString())
        @$el.toggleClass('active', isNewChoice)
      else
        @$el.removeClass('active') unless @multiSelect

    # Right, this should clearly be a model - FIXME
    @listenTo @model, 'change:filter', (m, terms) =>
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


  rendered: false

  render: () ->
      disabled = @getDisabled(@path)
      @$el.addClass('disabled') if disabled
      @rendered = true
      @path.getDisplayName().then (name) =>
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
        .removeClass(intermine.icons.Collapsed)
        .addClass(intermine.icons.Expanded)
      @subfinder = new PathChooser(@query, @path, @depth + 1, @evts, @getDisabled, @isSelectable, @multiSelect)
      @subfinder.allowRevRefs @allowRevRefs

      @$el.append @subfinder.render().el

    template: (data) -> _.template """<a href="#">
          <i class="#{ intermine.icons.Collapsed } im-has-fields"></i>
          <% if (isLoop) { %>
            <i class="#{ intermine.icons.ReverseRef }"></i>
          <% } %>
          <span><%- name %></span>
        </a>
        """, data

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
          @evts.trigger 'collapse:tree-branches'
        @state.on 'change:allowRevRefs', => @render() if @rendered # Re-render.

    allowRevRefs: (allowed) =>
      @state.set allowRevRefs: allowed

    remove: ->
      @evts.off() if @depth is 0
      @state.off()
      super()
            
    reset: ->
      @$root?.remove()
      while leaf = @leaves.pop()
        leaf.remove()

    render: () ->
      @reset()
      @rendered = true
      cd = @path.getEndClass()
      if @depth is 0 and @canSelectRefs # then show the root class
        @$root = new RootClass(@query, cd, @evts, @multiSelect)
        @$el.append @$root.render().el

      for apath in @attributes
        if intermine.options.ShowId or apath.end.name isnt 'id'
          attr = new Attribute(@query, apath, @depth, @evts, @getDisabled, @multiSelect)
          @leaves.push attr

      for rpath in @references.concat(@collections)
        isLoop = false
        if rpath.end.reverseReference? and @path.isReference()
          if @path.getParent().isa rpath.end.referencedType
            if @path.end.name is rpath.end.reverseReference
              isLoop = true

        # TODO. Clean this up with an options constructor.
        allowingRevRefs = @state.get('allowRevRefs')
        ref = if isLoop and not allowingRevRefs
            new ReverseReference(@query, rpath, @depth, @evts, (() -> true), @multiSelect, @canSelectRefs)
        else
            new Reference(@query, rpath, @depth, @evts, @getDisabled, @multiSelect, @canSelectRefs)

        ref.allowRevRefs = allowingRevRefs
        ref.isLoop = isLoop
        @leaves.push ref

      for leaf in @leaves
        @$el.append leaf.render().el

      @$el.addClass(@dropDownClasses) if @depth is 0
      @$el.show()
      this

module.exports = class ConstraintAdder extends View

  tagName: 'div'

  className: 'im-constraint-adder row-fluid'

  initialize: ({@query}) ->
    super
    @model.set
      root: @query.getPathInfo(@query.root)
      showTree: false
      refsOK: true
      multiSelect: false

    @openNodes = new Backbone.Collection
    @listenTo @model, 'change:chosen', @handleChoice
    @listenTo @model, 'change:showTree', @toggleTree
    @listenTo @query, 'change:constraints', @remove # our job is done

  getTreeRoot: -> @model.get 'root'

  events: ->
    'submit': 'handleSubmission'
    'click .im-collapser': 'collapseBranches'
    'change .im-allow-rev-ref': 'toggleReverseRefs'

  collapseBranches: -> @openNodes.reset()

  toggleReverseRefs: -> @model.toggle 'allowRevRefs'

  handleSubmission: (e) => # TODO - ensure that this is based on model events.
    e.preventDefault()
    e.stopPropagation()
    if @model.has 'chosen' # FIXME - ensure that this model value is populated
      con = path: @model.get('chosen').toString()
      @renderChild 'newcon', (new NewConstraint {@query, con}), @$ '.new-constraint'
      @$('.btn-primary').fadeOut('fast') # Only add one constraint at a time...
      @removeChild 'pathfinder'
      @query.trigger 'editing-constraint'
    else
      console.debug "Nothing chosen"

  handleChoice: ->
    @$('.btn-primary').fadeToggle @model.has 'chosen'

  isDisabled: (path) -> false

  toggleTree: ->
    if @model.get('showTree')
      @showTree()
    else
      @hideTree()

  hideTree: -> @
    @trigger 'resetting:tree'
    @$('.im-tree-option').addClass 'hidden'
    @removeChild 'pathfinder'

  showTree: (e) =>
    @trigger 'showing:tree'
    @$('.im-tree-option').removeClass 'hidden'
    pathFinder = new PathChooser {@model, @query, @openNodes, path: []}
    @renderChild 'pathfinder', pathFinder, @$ '.path-finder'
    pathFinder.$el.show().css top: @$el.height() # I do not like this...

  VALUE_OPS = Query.ATTRIBUTE_VALUE_OPS.concat(Query.REFERENCE_OPS)

  # isValid: () -> is this needed?
  #   if @newCon?
  #     if not @newCon.con.has('op')
  #       return false
  #     if @newCon.con.get('op') in VALUE_OPS
  #       return @newCon.con.has('value')
  #     if @newCon.con.get('op') in intermine.Query.MULTIVALUE_OPS
  #         return @newCon.con.has('values')
  #     return true
  #   else
  #     return false

  getData: ->
    return _.extend {messages: Messages, icons: Icons}, data

  template: _.template """
    <button type="button" class="btn btn-chooser" data-toggle="button">
      <%- icons.icon('Tree') %>
      <span><%= messages.getMessage('constraints.BrowseForColumn') %></span>
    </button>
  """

  render: ->
    @removeChild 'pathfinder' # CONTINUE FROM HERE
    
      browser = $ """
        <button type="button" class="btn btn-chooser" data-toggle="button">
          <i class="#{ intermine.icons.Tree }"></i>
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
