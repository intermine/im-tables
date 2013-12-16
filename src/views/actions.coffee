Backbone = require 'backbone'
ListManager = require './list-manager'
CodeGenerator = require './code-generator'

class exports.Actions extends Backbone.View

  className: "im-query-actions row-fluid"
  tagName: "ul"

  initialize: (@states) ->

  actionClasses: -> [ListManager, CodeGenerator]
  extraClass: "im-action"
  render: ->
    for cls in @actionClasses()
      action = new cls @states
      action.render().$el.addClass(@extraClass).appendTo @el unless action.disabled

    this
