Backbone = require 'backbone'
_ = require 'underscore'
$ = require 'jquery'
options = require '../../options'

class exports.Attribute extends Backbone.View

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
      @listenTo @evts, 'remove', () => @remove()
      @listenTo @evts, 'chosen', (p, isNewChoice) =>
          if (p.toString() is @path.toString())
              @$el.toggleClass('active', isNewChoice)
          else
              @$el.removeClass('active') unless @multiSelect

      @listenTo @evts, 'filter:paths', (terms) =>
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

  remove: ->
    for prop in ['query', 'path', 'depth', 'evts', 'getDisabled', 'multiSelect']
      delete @[prop]
    super arguments...

  template: _.template """
    <a title="<%- path %> (<%- type %>)">
      <span><%- name %></span>
    </a>
  """

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
      if options.ShowId
          a.tooltip(placement: 'bottom').appendTo @el
      else
          a.attr title: ""

