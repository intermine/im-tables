_ = require 'underscore'
fs = require 'fs'
{Promise} = require 'es6-promise'

Messages = require '../messages'
View = require '../core-view'

helpers = require '../templates/helpers'
mustacheSettings = require '../templates/mustache-settings'

html = fs.readFileSync __dirname + '/../templates/list-value-controls.html', 'utf8'
template = _.template html
formatList = (list) -> "#{ list.name } (#{ list.size } #{ list.typeName }s"

# Promise to add a typeName property to the list.
# :: Query -> List -> Promise<ExtendedList>
withDisplayNames = (m) -> (l) ->
  p = m.makePath l.type
  p.getDisplayName().then (typeName) -> _.extend l, {typeName}

module.exports = class ListValueControls extends View

  initialize: ({@query}) ->
    super
    @path = @model.get 'path'
    @setSuitableLists()
    @listenTo @model, 'change', @reRender

  events: ->
    'change select': 'setList'

  setList: -> @model.set value: @$('select').val()

  setSuitableLists: -> unless @model.has 'suitableLists'
    @getSuitableLists().then (suitableLists) => @model.set {suitableLists}

  getSuitableLists: -> # Cache this result, since we don't want to keep fetching it.
    @__suitable_lists ?= @query.service.fetchLists().then (lists) =>
      selectables = (l for l in lists when l.size and @path.isa l.type)
      Promise.all selectables.map withDisplayNames @query.model

  template: (data) ->
    data = _.extend {formatList}, helpers, data
    template data

  getData: ->
    currentValue = @model.get 'value'
    suitableLists = (@model.get('suitableLists') or [])
    isSelected = (opt) -> opt.name is currentValue
    {suitableLists, isSelected}


