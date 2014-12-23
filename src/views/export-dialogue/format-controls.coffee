_ = require 'underscore'
View = require '../../core-view'
Messages = require '../../messages'
Templates = require '../../templates'
LabelView = require '../label-view'

# There are no good bio icons in the font-awesome
# set, but there are tickets to get them put in. Maybe
# one day soon these will work.
formats = [
  {id: 'tab', icon: 'tsv', key: 'export.description.Tab'}
  {id: 'csv', icon: 'csv', key: 'export.description.CSV'}
  {id: 'xml', icon: 'xml', key: 'export.description.XML'}
  {id: 'json', icon: 'json', key: 'export.description.JSON'}
  {id: 'fasta', icon: 'dna', key: 'export.description.FASTA'}
  {id: 'gff3', icon: 'dna', key: 'export.description.GFF3'}
  {id: 'bed', icon: 'dna', key: 'export.description.BED'}
]

class HeadingView extends LabelView

  template: _.partial Messages.getText, 'export.category.Format'

module.exports = class FormatControls extends View

  tagName: 'form'

  template: Templates.template 'export_format_controls'

  getData: -> _.extend {formats}, super

  events: ->
    'change input:radio': 'onChangeFormat'

  onChangeFormat: ->
    @model.set format: @$('input:radio:checked').val()

  postRender: ->
    @renderChild 'heading', (new HeadingView {@model}), @$ 'h3'

