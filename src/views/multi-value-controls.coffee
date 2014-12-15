_ = require 'underscore'
{Collection} = require 'backbone'
fs = require 'fs'

Messages = require '../messages'
View = require '../core-view'
Model = require '../core-model'
Options = require '../options'

mustacheSettings = require '../templates/mustache-settings'

valueRow = fs.readFileSync __dirname + '/../templates/value-control-row.html', 'utf8'

class ValueControl extends View

  tagName: 'tr'

  initialize: ->
    @listenTo @model, 'change', @reRender

  events: ->
    'click': 'toggleSelected' # Very broad - want to capture row clicks too.

  toggleSelected: -> @model.toggle 'selected'

  template: _.template valueRow, mustacheSettings

module.exports = class MultiValueControls extends View

  className: 'im-value-options im-multi-value-table'

  initialize: ->
    super
    @values = new Collection
    for v in @model.get('values')
      @values.add new Model value: v, selected: true
    @listenTo @values, 'change:selected', @updateModel

  updateModel: ->
    @model.set values: (m.get 'value' for m in @values.where selected: true)

  template: -> '<table class="table table-condensed"></table>'

  render: ->
    super
    @renderRows @$ 'table'

  renderRows: (container) -> @values.each (m, i) =>
    @renderChild i, (new ValueControl model: m), container

