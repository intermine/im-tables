_ = require 'underscore'
fs = require 'fs'
{Promise} = require 'es6-promise'

Messages = require '../messages'
View = require '../core-view'

helpers = require '../templates/helpers'
mustacheSettings = require '../templates/mustache-settings'
toNamedPath = require '../utils/to-named-path'

html = fs.readFileSync __dirname + '/../templates/loop-value-controls.html', 'utf8'
template = _.template html

toOption = ({path, name}) -> value: path.toString(), text: name

module.exports = class LoopValueControls extends View

  initialize: ({@query}) ->
    super
    @path = @model.get 'path'
    @type = @path.getType()
    @setCandidateLoops()
    @listenTo @model, 'change', @reRender

  events: ->
    'change select': 'setLoop'

  setLoop: -> @model.set value: @$('select').val()

  setCandidateLoops: -> unless @model.has 'candidateLoops'
    @getCandidateLoops().then (candidateLoops) => @model.set {candidateLoops}

  # Cache this result, since we don't want to keep fetching display names.
  getCandidateLoops: -> @__candidate_loops ?= do =>
    loopCandidates = @query.getQueryNodes().filter (candidate) =>
      (candidate.isa @type) or (@path.isa candidate.getType())

    Promise.all loopCandidates.map toNamedPath

  template: (data) ->
    template _.extend {}, helpers, data

  getData: ->
    currentValue = @model.get 'value'
    candidateLoops = (toOption c for c in (@model.get('candidateLoops') or []))
    isSelected = (opt) -> opt.value is currentValue
    {candidateLoops, isSelected}


