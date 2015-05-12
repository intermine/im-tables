$ = require 'jquery'
_ = require 'underscore'
{Promise} = require 'es6-promise'

Messages = require '../messages'
Templates = require '../templates'
CoreView = require '../core-view'
Options = require '../options'
NestedModel = require '../core/nested-model'
getBranding = require '../utils/branding'
{IS_BLANK} = require '../patterns'
HasTypeaheads = require '../mixins/has-typeaheads'

SuggestionSource = require '../utils/suggestion-source'

{Model: {INTEGRAL_TYPES, NUMERIC_TYPES}, Query} = require 'imjs'

selectTemplate = Templates.template 'attribute_value_select'

trim = (s) -> String(s).replace(/^\s+/, '').replace(/\s+$/, '')

numify = (x) -> 1 * trim x

{numToString} = require '../templates/helpers'

Messages.set
  'constraintvalue.NoValues': 'There are no possible values. This query returns no results'
  'constraintvalue.OneValue': """
    There is only one possible value: <%- value %>. You might want to remove this constraint
  """

module.exports = class AttributeValueControls extends CoreView
  
  @include HasTypeaheads

  className: 'im-attribute-value-controls'

  template: Templates.template 'attribute_value_controls'

  getData: -> _.extend @getBaseData(), messages: Messages, con: @model.toJSON()

  # @Override
  initialize: ({@query}) ->
    super
    @sliders = []
    @branding = new NestedModel
    @cast = if @model.get('path').getType() in NUMERIC_TYPES then numify else trim
    # Declare rendering dependency on messages
    @listenTo Messages, 'change', @reRender
    @state.set valuePlaceholder: Messages.getText('conbuilder.ValuePlaceholder')
    @listenTo @branding, 'change:defaults.value', ->
      @state.set valuePlaceholder: @branding.get('defaults.value')
    if @query?
      @listenTo @query, 'change:constraints', @clearCachedData
      @listenTo @query, 'change:constraints', @reRender
      getBranding(@query.service).then (branding) => @branding.set(branding)

  modelEvents: ->
    destroy: -> @stopListening() # If the model is gone, then shut up and wait to be removed.
    'change:value': @onChangeValue
    'change:op': @onChangeOp

  stateEvents: ->
    'change:valuePlaceholder': @reRender

  # Help translate between multi-value and =
  onChangeOp: ->
    newOp = @model.get 'op'
    if newOp in Query.MULTIVALUE_OPS
      @model.set value: null, values: [@model.get('value')]
    @reRender()

  onChangeValue: -> @updateInput()

  removeAllChildren: ->
    @removeTypeAheads()
    @removeSliders()
    super

  removeSliders: ->
    while sl = @sliders.pop()
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

  postRender: ->
    @provideSuggestions().then null, (error) => @model.set {error}
    @$('.im-con-value-attr').focus()

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
    return Promise.reject(new Error 'no path') unless @model.get 'path'
    clone = @query.clone()
    value = @model.get 'value'
    pstr = String @model.get 'path'
    maxSuggestions = Options.get 'MaxSuggestions'
    clone.constraints = (c for c in clone.constraints when not (c.path is pstr and c.value is value))

    clone.summarise pstr, maxSuggestions

  replaceInputWithSelect: (items) ->
    console.log("Select of #{ items.length } items")
    if @model.has 'value'
      value = @model.get('value')
      if value? and not (_.any items, ({item}) -> item is value)
        items.push item: value
    else
      @model.set value: items[0].item

    @$el.html selectTemplate {Messages, items, value}

  # Here we supply the suggestions using typeahead.js
  # see: https://github.com/twitter/typeahead.js/blob/master/doc/jquery_typeahead.md
  handleSummary: (items, total) ->
    if @model.get('op') in ['=', '!='] and items.length < Options.get 'DropdownMax'
      return @replaceInputWithSelect items

    input = @$ '.im-con-value-attr'
    source = new SuggestionSource items, total

    opts =
      minLength: 0
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

  makeSlider: (Templates.template 'slider', variable: 'markers')

  handleNumericSummary: ({min, max, average}) ->
    path = @model.get 'path'
    isInt = path.getType() in INTEGRAL_TYPES
    step = if isInt then 1 else (max - min / 100)
    caster = if isInt then ((x) -> parseInt(x, 10)) else parseFloat
    container = @$el
    input = @$ 'input'
    container.append @clearer
    markers = @getMarkers min, max, isInt
    @removeSliders()
    input.off 'change.slider'
    $slider = $ @makeSlider markers
    $slider.appendTo(container).slider
      min: min
      max: max
      value: (if @model.has('value') then @model.get('value') else caster average)
      step: step
      slide: (e, ui) -> input.val(ui.value).change()
    input.attr placeholder: caster average
    container.append @clearer
    input.on 'change.slider', (e) -> $slider.slider 'value', caster input.val()
    @sliders.push $slider

  remove: ->
    super
    @removeTypeAheads()
