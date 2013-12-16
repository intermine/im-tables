Backbone = require 'backbone'
_ = require 'underscore'

{RootClass} = require './path-chooser/root'
{Attribute} = require './path-chooser/attribute'
{Reference} = require './path-chooser/reference'
{ReverseReference} = require './path-chooser/rev-reference'

options = require '../options'

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
        if options.ShowId or apath.end.name isnt 'id'
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

