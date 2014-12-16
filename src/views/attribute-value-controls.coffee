$ = require 'jquery'
_ = require 'underscore'
fs = require 'fs'

Messages = require '../messages'
View = require '../core-view'
Options = require '../options'
SuggestionSource = require '../utils/suggestion-source'

{Model: {INTEGRAL_TYPES, NUMERIC_TYPES}} = require 'imjs'

html = fs.readFileSync __dirname + '/../templates/attribute-value-controls.html', 'utf8'

trim = (s) -> String(s).replace(/^\s+/, '').replace(/\s+$/, '')

numify = (x) -> 1 * trim x

module.exports = class AttributeValueControls extends View

  className: 'im-attribute-value-controls'

  template: _.template html

  getData: -> messages: Messages, con: @model.toJSON()

  # @Override
  initialize: ({@query}) ->
    super
    @typeaheads = []
    @sliders = []
    @cast = if @model.get('path').getType() in NUMERIC_TYPES then numify else trim
    # Declare rendering dependency on messages
    @listenTo Messages, 'change', @reRender

  removeWidgets: ->
    @removeTypeAheads()
    @removeSliders()

  removeTypeAheads: ->
    while (ta = @typeaheads.shift())
      ta.off('typeahead:selected')
      ta.off('typeahead:autocompleted')
      ta.typeahead('destroy')
      ta.remove()

  removeSliders: ->
    while (sl = @sliders.shift())
      sl.slider('destroy')
      sl.remove()

  events: ->
    'change .im-con-value-attr': 'setAttributeValue'

  readAttrValue: ->
    raw = @$('.im-con-value-attr').val()
    try
      @cast raw # to string or number, as per path type
    catch e
      @model.set error: new Error("#{ raw } might not be a legal value for #{ @path }")
      raw

  setAttributeValue: -> @model.set value: @readAttrValue()

  # @Override
  render: ->
    @removeWidgets()
    super
    @provideSuggestions().then null, (error) => @model.set {error}
    this

  provideSuggestions: -> @getSuggestions().then ({stats, results}) =>
    console.debug "Got #{ results?.length } suggestions"
    if results?.length # There is something
      if stats.max? # It is numeric summary
        @handleNumericSummary(stats)
      else # It is a histogram
        @handleSummary(results, stats.uniqueValues)

  getSuggestions: -> @__suggestions ?= do =>
    clone = @query.clone()
    pstr = @model.get('path').toString()
    value = @model.get('value')
    maxSuggestions = Options.get('MaxSuggestions')
    clone.constraints = (c for c in clone.constraints when not (c.path is pstr and c.value is value))

    clone.summarise pstr, maxSuggestions

  # Here we supply the suggestions using typeahead.js
  # see: https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md
  handleSummary: (items, total) ->
    input = @$ '.im-con-value-attr'

    source = new SuggestionSource items, total

    opts =
      minLength: 1
      highlight: true
    dataset =
      name: 'summary_suggestions'
      source: source.suggest
      displayKey: 'item'
      templates:
        footer: source.tooMany

    console.debug 'Installing typeahead on', input
    input.attr(placeholder: items[0].item).typeahead opts, dataset
    # Need to see if this needs hooking up...
    input.on 'typeahead:selected', (e, suggestion) =>
      @model.set value: suggestion.item
    input.on 'typeahead:autocompleted', (e, suggestion) =>
      @model.set value: suggestion.item

    # Keep a track of it, so it can be removed.
    @typeaheads.push input

  clearer: '<div class="" style="clear:both;">'

  handleNumericSummary: ({min, max, average}) ->
    path = @model.get 'path'
    isInt = path.getType() in INTEGRAL_TYPES
    step = if isInt then 1 else (max - min / 100)
    caster = if isInt then ((x) -> parseInt(x, 10)) else parseFloat
    container = @$el
    input = @$ 'input'
    container.append @clearer
    $slider = $ '<div class="im-value-options">'
    $slider.appendTo(container).slider
      min: min
      max: max
      value: (if @model.has('value') then @model.get('value') else caster average)
      step: step
      slide: (e, ui) -> input.val(ui.value).change()
    input.attr placeholder: caster average
    container.append @clearer
    input.change (e) -> $slider.slider 'value', caster input.val()
    @sliders.push $slider
