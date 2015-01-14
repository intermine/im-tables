_ = require 'underscore'

CoreView = require '../../core-view'
Templates = require '../../templates'

DOWN = 40
UP = 38
NULL_STATS =
  min: 0
  max: 0
  average: 0
  stdev: 0

module.exports = class SummaryStats extends CoreView

  RERENDER_EVENT: 'change'

  className: 'im-summary-stats'

  template: Templates.template 'summary_stats'

  # Ensure the template has the required values.
  getData: -> _.extend {}, NULL_STATS, super

  initialize: ({@range}) ->
    super
    @listenTo @range, 'change', @setSliderValues
    @listenTo @range, 'change', @setButtonDisabledness
    @listenTo @range, 'change:min', @onChangeMin
    @listenTo @range, 'change:max', @onChangeMax
    @listenForChange @model, @initType, 'integral', 'min', 'max'
    @initType()

  invariants: ->
    hasRange: "No range"

  hasRange: -> @range?

  setSliderValues: ->
    {min, max} = @range.toJSON()
    @$slider?.slider 'option', 'values', [min, max]

  # Max sure the text input reflects the state of the slider, and vice-versa
  onChangeMin: ->
    min = @range.get 'min'
    @$('input.im-range-min').val min
    if @$slider? and (@$slider.slider('values', 0) isnt min)
      @$slider.slider 'values', 0, min

  # Max sure the text input reflects the state of the slider, and vice-versa
  onChangeMax: ->
    max = @range.get 'max'
    @$('input.im-range-max').val max
    if @$slider? and (@$slider.slider('values', 1) isnt max)
      @$slider.slider 'values', 1, max

  setButtonDisabledness: ->
    changed = @range.isNotAll()
    @$('.btn').toggleClass 'disabled', (not changed)

  events: ->
    'click': (e) -> e.stopPropagation()
    'keyup input.im-range-min': 'maybeIncrementMin'
    'keyup input.im-range-max': 'maybeIncrementMax'
    'change input.im-range-min': 'setRangeMin'
    'change input.im-range-max': 'setRangeMax'
    'click .btn-primary': 'changeConstraints'
    'click .btn-cancel': 'clearRange'

  clearRange: -> @range?.reset()

  maybeIncrementMin: (e) -> @maybeIncrement 'min', e

  maybeIncrementMax: (e) -> @maybeIncrement 'max', e

  maybeIncrement: (prop, e) ->
    value = @range.get prop
    switch e.keyCode
      when DOWN then value -= @step
      when UP then value += @step

    @range.set prop, value

  setRangeMin: ->
    @range.set min: @parse @$('.im-range-min').val()

  setRangeMax: ->
    @range.set max: @parse @$('.im-range-max').val()

  changeConstraints: (e) ->
    e.preventDefault()
    e.stopPropagation()

    path = @model.view.toString()
    query = @model.query
    existingConstraints =  _.where query.constraints, {path}

    newConstraints if @range.nulled
      [{path, op: 'IS NULL'}]
    else
      [
        {
          path: path
          op: ">="
          value: @range.get('min')
        },
        {
          path: path
          op: "<="
          value: @range.get('max')
        }
      ]

    # remove silently, since we will be triggering the change next.
    for c in existingConstraints
      query.removeConstraint c, silent: true

    query.addConstraints newConstraints

  postRender: -> @drawSlider()

  parse: (str) ->
    try
      if @step is 1 then parseInt(str, 10) else parseFloat(str)
    catch e
      @model.set error: new Error "Could not parse '#{ str }' as a number"
      null

  initType: -> # sets step and the rounding function.
    # For intish columns the step is 1, otherwise it is 1% of the range.
    {integral, min, max} = @model.toJSON()
    @step = if integral then 1 else Math.abs((max - min) / 100)
    @round = if integral then Math.round else _.identity

  drawSlider: ->
    {max, min} = @model.pick 'min', 'max'
    @activateSlider
      range: true
      min: min
      max: max
      values: [min, max]
      step: @step
      slide: (e, ui) => @range?.set min: ui.values[0], max: ui.values[1]

  reRender: ->
    @destroySlider()
    super

  activateSlider: (opts) ->
    @destroySlider() # remove previous slider if present.
    @$slider = @$ '.slider'
    @$slider.slider opts

  destroySlider: -> if @$slider?
    @$slider.slider 'destroy'
    @$slider = null

  remove: ->
    @destroySlider()
    super

