_ = require 'underscore'
View = require '../../core-view'
Templates = require '../../templates'

module.exports = class FlatFileOptions extends View

  RERENDER_EVENT: 'change'

  tagName: 'form'

  template: Templates.template 'export_flat_file_options'

  setHeaderType: (type) -> => @model.set headerType: type

  events: ->
    'click .im-headers': => @model.toggle 'headers'
    'click input[name=hdrs-friendly]': @setHeaderType 'friendly'
    'click input[name=hdrs-path]': @setHeaderType 'path'

