_ = require 'underscore'
$ = require 'jquery'

icons = require '../../icons'

{Attribute} = require './attribute'

class exports.Reference extends Attribute

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
        .removeClass(icons.Expanded)
        .addClass(icons.Collapsed)

    remove: () ->
      @collapse()
      super()

    openSubFinder: () ->
      @$el.addClass('open')
      @$('i.im-has-fields')
        .addClass(icons.Expanded)
        .removeClass(icons.Collapsed)
      @subfinder = new PathChooser(@query, @path, @depth + 1, @evts, @getDisabled, @isSelectable, @multiSelect)
      @subfinder.allowRevRefs @allowRevRefs

      @$el.append @subfinder.render().el

    template: _.template """
        <a>
          <i class="#{ icons.Collapsed } im-has-fields"></i>
          <% if (isLoop) { %>
            <i class="#{ icons.ReverseRef }"></i>
          <% } %>
          <span><%- name %></span>
        </a>
        """

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

