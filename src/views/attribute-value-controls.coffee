$ = require 'jquery'
_ = require 'underscore'
fs = require 'fs'

Messages = require '../messages'
View = require '../core-view'
Options = require '../options'
{IS_BLANK} = require '../patterns'
mixOf = require '../mix-of'
HasTypeaheads = require '../mixins/has-typeaheads'

SuggestionSource = require '../utils/suggestion-source'

{Model: {INTEGRAL_TYPES, NUMERIC_TYPES}, Query} = require 'imjs'

html = fs.readFileSync __dirname + '/../templates/attribute-value-controls.html', 'utf8'
slider_html = fs.readFileSync __dirname + '/../templates/slider.html', 'utf8'

trim = (s) -> String(s).replace(/^\s+/, '').replace(/\s+$/, '')

numify = (x) -> 1 * trim x

{numToString} = require '../templates/helpers'

Messages.set
  'constraintvalue.NoValues': 'There are no possible values. This query returns no results'
  'constraintvalue.OneValue': """
    There is only one possible value: <%- value %>. You might want to remove this constraint
  """

module.exports = class AttributeValueControls extends mixOf View, HasTypeaheads

  className: 'im-attribute-value-controls'

  template: _.template html

  getData: -> messages: Messages, con: @model.toJSON()

  # @Override
  initialize: ({@query}) ->
    super
    @sliders = []
    @cast = if @model.get('path').getType() in NUMERIC_TYPES then numify else trim
    # Declare rendering dependency on messages
    @listenTo Messages, 'change', @reRender
    @listenTo @model, 'change:value', @updateInput
    if @query?
      @listenTo @query, 'change:constraints', @clearCachedData
      @listenTo @query, 'change:constraints', @reRender
    # Help translate between multi-value and =
    @listenTo @model, 'change:op', =>
      newOp = @model.get 'op'
      if newOp in Query.MULTIVALUE_OPS
        @model.set value: null, values: [@model.get('value')]

  remove: ->
    @removeTypeAheads()
    @removeSliders()
    super

  removeSliders: ->
    while (sl = @sliders.shift())
      try
        sl.slider('destroy')
        sl.remove()

  events: ->
    'change .im-con-value-attr': 'setAttributeValue'

  updateInput: ->
    input = (@lastTypeahead() ? @$('.im-con-value-attr'))
    input.val @model.get 'value'

  readAttrValue: ->
    raw = (@lastTypeahead() ? @$('.im-con-value-attr')).val()
    try
      #  to string or number, as per path type
      if (raw? and not IS_BLANK.test raw) then @cast(raw) else null
    catch e
      @model.set error: new Error("#{ raw } might not be a legal value for #{ @path }")
      raw

  setAttributeValue: -> @model.set value: @readAttrValue()

  # @Override
  render: ->
    super
    @provideSuggestions().then null, (error) => @model.set {error}
    this

  provideSuggestions: -> @getSuggestions().then ({stats, results}) =>
    if stats.uniqueValues is 0
      msg = Messages.getText 'constraintvalue.NoValues'
      @model.set error: {message: msg, level: 'warning'}
    else if stats.uniqueValues is 1
      msg = Messages.getText 'constraintvalue.OneValue', value: results[0].item
      @model.set error: {message: msg, level: 'warning'}
    else if stats.max? # It is numeric summary
      @handleNumericSummary(stats)
    else if results[0].item? # It is a histogram
      @handleSummary(results, stats.uniqueValues)

  # Need to do this when the query changes.
  clearCachedData: ->
    delete @__suggestions
    @model.unset 'error'

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

    @removeTypeAheads()
    @activateTypeahead input, opts, dataset, items[0].item, (e, suggestion) =>
      @model.set value: suggestion.item

  clearer: '<div class="" style="clear:both;">'
  
  getMarkers: (min, max, isInt) ->
    span = max - min
    getValue = (frac) ->
      val = frac * span + min
      if isInt then Math.round(val) else val
    getPercent = (frac) -> Math.round 100 * frac

    ({percent: getPercent(f), value: numToString(getValue(f))} for f in [0, 0.5, 1])

  makeSlider: _.template slider_html, variable: 'markers'

  handleNumericSummary: ({min, max, average}) ->
    path = @model.get 'path'
    isInt = path.getType() in INTEGRAL_TYPES
    step = if isInt then 1 else (max - min / 100)
    caster = if isInt then ((x) -> parseInt(x, 10)) else parseFloat
    container = @$el
    input = @$ 'input'
    container.append @clearer
    markers = @getMarkers min, max, isInt
    $slider = $ @makeSlider markers
    $slider.appendTo(container).slider
      min: min
      max: max
      value: (if @model.has('value') then @model.get('value') else caster average)
      step: step
      slide: (e, ui) -> input.val(ui.value).change()
    input.attr placeholder: caster average
    container.append @clearer
    input.change (e) -> $slider.slider 'value', caster input.val()
    @removeSliders()
    @sliders.push $slider
