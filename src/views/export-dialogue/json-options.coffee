_ = require 'underscore'
View = require '../../core-view'
LabelView = require '../label-view'
Messages = require '../../messages'
Templates = require '../../templates'

module.exports = class JSONOptions extends View

  RERENDER_EVENT: 'change'

  tagName: 'form'

  template: Templates.template 'export_json_options'

  setJSONFormat: (fmt) -> => @model.set jsonFormat: fmt

  events: ->
    'click input[name=rows]': @setJSONFormat 'rows'
    'click input[name=objects]': @setJSONFormat 'objects'

