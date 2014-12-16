$ = require 'jquery'
_ = require 'underscore'
fs = require 'fs'

Messages = require '../messages'
View = require '../core-view'
Options = require '../options'
{IS_BLANK} = require '../patterns'

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
    @listenTo @query, 'change:constraints', @clearCachedData
    @listenTo @query, 'change:constraints', @reRender

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
    raw = (_.last(@typeaheads) ? @$('.im-con-value-attr')).val()
    try
      #  to string or number, as per path type
      if (raw? and not IS_BLANK.test raw) then @cast(raw) else null
    catch e
      @model.set error: new Error("#{ raw } might not be a legal value for #{ @path }")
      raw

  setAttributeValue: -> @model.set value: @readAttrValue()

  # @Override
  render: ->
    console.debug 'rendering value controls'
    @removeWidgets()
    super
    @provideSuggestions().then null, (error) => @model.set {error}
    this

  provideSuggestions: -> @getSuggestions().then ({stats, results}) =>
    console.debug 'summary:', stats, results
    if results?.length # There is something
      if stats.uniqueValues is 1
        msg = "there is only one possible value: #{ results[0].item }"
        @model.set error: {message: msg, level: 'warning'}
      else if stats.max? # It is numeric summary
        @handleNumericSummary(stats)
      else if results[0].item? # It is a histogram
        @handleSummary(results, stats.uniqueValues)

  # Need to do this when the query changes.
  clearCachedData: ->
    console.debug 'clearing cached data'
    delete @__suggestions
    @model.unset 'error'

  getSuggestions: -> @__suggestions ?= do =>
    console.debug 'getting suggestions'
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

    console.debug 'Installing typeahead on', input[0]
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
