"use strict"

$ = require "jquery"
{connection} = require '../lib/connect-to-service'

Backbone = require 'backbone'
CoreView = require 'imtables/core-view'
Templates = require 'imtables/templates'
Preview = require 'imtables/views/item-preview'
PopoverFactory = require 'imtables/utils/popover-factory'
Options = require 'imtables/options'

colleaguesQuery = (id) ->
  from: 'Employee'
  select: 'department.employees.id'
  where: [
    ['id', '=', id],
    ['department.employees.id', '!=', id]
  ]

opts =
  Department: ['employees']
  Employee: [{label: 'Colleagues', query: colleaguesQuery}]

Options.set ['Preview', 'Count', connection.root], opts

classyPopover = Templates.template 'classy-popover'

popoverFactory = new PopoverFactory connection, Preview

class Button extends CoreView

  className: 'btn btn-default'

  tagName: 'button'

  attributes:
    style: 'margin:10px'

  template: -> "#{ @model.get 'type' }: #{ @model.get 'name' }"

  events: -> click: @triggerPopover

  stateEvents: ->
    'change:showPopover': @togglePopover

  triggerPopover: -> @state.toggle 'showPopover'

  togglePopover: ->
    show = @state.get 'showPopover'
    if show
      @popover?.then (v) -> v.render()
    else
      @$el.popover 'hide'

  postRender: ->
    @popover ?= @initPopover()
    @popover.then null, (e) ->
      console.error 'Failed to init popover', e
    
  # :: Promise<View>
  initPopover: ->
    {type, name} = @model.toJSON()
    getContent = fetchId(find type, name).then getPopoverContent type
    getContent.then (view) =>
      console.log view
      @listenTo view, 'rendered', => @$el.popover 'show'
      @$el.popover
        trigger: 'manual'
        template: (classyPopover classes: 'item-preview')
        placement: 'auto left'
        container: @$el.closest('.panel')
        title: @model.get('type')
        html: true
        content: view.el
        viewport:
          selector: 'body'
          padding: 5

    return getContent

main = ->
  renderButton 'Company', 'Wernham-Hogg'
  renderButton 'Employee', 'David Brent'
  renderButton 'Employee', 'David Brent' # yes, twice.
  renderButton 'Department', 'Verwaltung'
  renderButton 'Secretary', 'Pam'

renderButton = (type, name) ->
  button = new Button model: {type, name}
  button.render().$el.appendTo '.panel-default'

fetchId = (query) -> connection.rows(query).then ([[id]]) -> id

find = (type, name) ->
  select: ['id']
  from: type
  where: {name}

getPopoverContent = (type) -> (id) ->
  # We need to wrap the factory method in a model, for that
  # is what it takes.
  popoverFactory.get new Backbone.Model {'class': type, id}

$ main
