_ = require 'underscore'
ModalBody = require './main'
Templates = require '../../templates'

module.exports = class CompressionControls extends ModalBody

  RERENDER_EVENT: 'change'

  tagName: 'form'

  template: Templates.template 'export_compression_controls'

  setCompression: (type) -> => @model.set compression: type

  events: ->
    'click .im-compress': => @model.toggle 'compress'
    'click input[name=gzip]': @setCompression 'gzip'
    'click input[name=zip]': @setCompression 'zip'

