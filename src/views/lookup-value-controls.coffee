_ = require 'underscore'
fs = require 'fs'
{Promise} = require 'es6-promise'

SuggestionSource = require '../utils/suggestion-source'
Messages = require '../messages'
AttributeValueControls = require './attribute-value-controls'

html = fs.readFileSync __dirname + '/../templates/extra-value-controls.html', 'utf8'

template = _.template html

module.exports = class LoopValueControls extends AttributeValueControls

  initialize: ->
    super # sets query, branding, etc.
    @state.set extraPlaceholder: Messages.get('conbuilder.ExtraPlaceholder')
    @listenTo @branding, 'change:defaults.extraValue.path', @reRender
    @listenTo @branding, 'change:defaults.extraValue.value', ->
      @state.set extraPlaceholder: @branding.get('defaults.extraValue.value')
    # The following is fairly brutal, but it was the only way to get correct
    # rendering with type-aheads.
    @listenTo @model, 'change', @reRender

  stateEvents: -> _.extend super,
    'change:extraPlaceholder': @reRender

  template: (data) ->
    base = super
    base + template data

  events: ->
    'change .im-con-value-attr': 'setValue'
    'change .im-extra-value': 'setExtraValue'

  setExtraValue: ->
    input = @$('input.im-extra-value.tt-input')
    input = @$('input.im-extra-value') unless input.length
    value = input.val()
    if value
      @model.set extraValue: value
    else
      @model.unset 'extraValue'

  setBoth: ->
    @setValue()
    @setExtraValue()

  suggestExtra: ->
    path = @branding.get('defaults.extraValue.path')
    target = @branding.get('defaults.extraValue.extraFor')
    suggestingExtra = if (not path? or not @model.get('path').isa(target))
      Promise.resolve(true)
    else
      summPath = "#{ @model.get 'path' }.#{ path }"
      suggesting = (@__extra_suggestions ?= @query.summarise(summPath))
      handler = @handleSuggestionSet.bind @, @$('input.im-extra-value'), 'extraValue'
      suggesting.then(({results}) -> results).then handler

  suggestValue: ->
    path = @model.get('path')
    s = @query.service
    cls = path.getEndClass().name
    gettingKeys = s.fetchClassKeys().then (keys) -> keys[cls]
    @__value_suggestions ?= gettingKeys.then (keys) =>
      return [] unless keys?.length
      summaries = (@query.summarise(path + k.replace(/^[^\.]+/, '')) for k in keys)
      Promise.all(summaries).then (resultSets) ->
        resultSets.reduce ((acc, rs) -> acc.concat(rs.results)), []
    handler = @handleSuggestionSet.bind(@, @$('input.im-con-value-attr'), 'value')
    @__value_suggestions.then handler

  handleSuggestionSet: (input, prop, results) ->
    total = results.length
    return if total is 0
    source = new SuggestionSource results, total
    opts =
      minLength: 0
      highlight: true
    dataset =
      name: "#{ prop }_suggestions"
      source: source.suggest
      displayKey: 'item'
      templates:
        footer: source.tooMany

    handleSuggestion = (control) => (e, suggestion) =>
      @model.set prop, suggestion.item
    mostCommon = results[0].item

    @activateTypeahead input, opts, dataset, mostCommon, (handleSuggestion input), => @setBoth()

  provideSuggestions: ->
    @removeTypeAheads()
    suggestingValue = @suggestValue()
    suggestingExtra = @suggestExtra()
    Promise.all([suggestingExtra, suggestingValue])

  remove: ->
    super
    @branding.destroy()

