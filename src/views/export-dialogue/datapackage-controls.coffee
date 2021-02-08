_ = require 'underscore'
ModalBody = require './main'
Templates = require '../../templates'

module.exports = class ExportDataPackageControls extends ModalBody

  RERENDER_EVENT: 'change'

  tagName: 'form'

  template: Templates.template 'export_data_package'

  events: ->
    'click .im-exportDataPackage': => @model.toggle 'exportDataPackage'

