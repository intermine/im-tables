_ = require 'underscore'
fs = require 'fs'
{Promise} = require 'es6-promise'

Messages = require '../messages'
View = require '../core-view'

Messages.set
  'convalue.BadType': "<%- name %> is of the wrong type (<%- type %>)."
  'convalue.EmptyList': "<%- name %> is empty. This query will always return 0 results"
  'convalue.BadList': """
    You do not have access to list called "<%- name %>". Choose one from the list.
  """

helpers = require '../templates/helpers'
mustacheSettings = require '../templates/mustache-settings'

html = fs.readFileSync __dirname + '/../templates/list-value-controls.html', 'utf8'
template = _.template html
getOptionValue = (list) -> list.name
formatList = (list) ->
  if list.size
    "#{ list.name } (#{ list.size } #{ list.typeName }s)"
  else
    list.name

# Promise to add a typeName property to the list.
# :: Query -> List -> Promise<ExtendedList>
withDisplayNames = (m) -> (l) ->
  p = m.makePath l.type
  p.getDisplayName().then (typeName) -> _.extend l, {typeName}

module.exports = class ListValueControls extends View

  className: 'im-list-value-controls'

  initialize: ({@query}) ->
    super
    @initialValue = @model.get 'value'
    @path = @model.get 'path'
    @setSuitableLists()
    @listenTo @model, 'change', @reRender
    @listenTo @model, 'change:value', @checkCurrentValue
    @checkCurrentValue()

  checkCurrentValue: ->
    name = @model.get 'value'
    doesntExist = (error) =>
      @model.set error: new Error Messages.getText 'convalue.BadList', {name}
      @listenToOnce @model, 'change:value', => @model.unset 'error'
    exists = (list) ->
      err = if not list.size
        'convalue.EmptyList'
      else if not @path.isa list.type
        'convalue.BadType'

      if err?
        @model.set error: new Error Messages.getText err, list
        @listenToOnce @model, 'change:value', => @model.unset 'error'

    @query.service.fetchList(name).then exists, doesntExist

  events: ->
    'change select': 'setList'

  setList: -> @model.set value: @$('select').val()

  setSuitableLists: -> unless @model.has 'suitableLists'
    success = (suitableLists) => @model.set {suitableLists}
    failed = (error) => @model.set {error}
    @fetchSuitableLists().then success, failed

  fetchSuitableLists: -> # Cache this result, since we don't want to keep fetching it.
    @__suitable_lists ?= @query.service.fetchLists().then (lists) =>
      selectables = (l for l in lists when l.size and @path.isa l.type)
      Promise.all selectables.map withDisplayNames @query.model

  getSuitableLists: ->
    currentValue = name: @initialValue
    suitableLists = (@model.get('suitableLists') or [])
    currentlySelected = _.findWhere suitableLists, currentValue
    currentlySelected ?= currentValue
    _.uniq [currentlySelected].concat(suitableLists), false, 'name'

  template: (data) ->
    data = _.extend {formatList, getOptionValue, messages: Messages}, helpers, data
    template data

  getData: ->
    currentValue = @model.get 'value'
    suitableLists = @getSuitableLists()
    isSelected = (opt) -> opt.name is currentValue
    {suitableLists, isSelected}

