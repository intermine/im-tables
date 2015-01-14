_ = require 'underscore'
{View, Model} = require 'backbone'

module.exports = class ModelDisplay extends View

  tagName: 'code'

  style:
    position: 'fixed'
    overflow: 'auto'
    bottom: 0
    'font-size': '12px'

  initialize: ->
    @state = new Model minimised: true
    @listenTo @model, 'change', @render
    @listenTo @model, 'change:error', @logError
    @listenTo @state, 'change:minimised', @toggleMinimised

  toggleMinimised: ->
    maxHeight = if @state.get('minimised') then '24px' else '300px'
    @el.style.maxHeight = maxHeight

  logError: -> if e = @model.get 'error'
    console.error(e, e.stack)

  events: ->
    click: 'handleClick'

  handleClick: (e) -> if e.ctrlKey
    @state.set minimised: (not @state.get 'minimised')

  render: ->
    @$el.css @style
    data = @model.toJSON()
    if data.error?.message
      data.error = data.error.message
    @$el.html _.escape JSON.stringify data, null, 2
    @toggleMinimised()

