_ = require 'underscore'
View = require '../../core-view'
LabelView = require '../label-view'
Messages = require '../../messages'
Templates = require '../../templates'

module.exports = class FastaOptions extends View

  RERENDER_EVENT: 'change'

  tagName: 'form'

  template: Templates.template 'export_fasta_options'

  setFastaExtension: (ext) -> @model.set fastaExtension: ext

  events: ->
    'change .im-fasta-ext': (e) => @setFastaExtension e.target.value

